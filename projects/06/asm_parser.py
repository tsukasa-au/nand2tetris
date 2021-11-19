#!/usr/bin/env python3
# vim: set ts=2 sts=2 et sw=2 ft=python:

import re
from absl import app
from absl import flags
FLAGS = flags.FLAGS

class Error(Exception):
  pass


_label_re = re.compile(r'\((.*)\)')


def _strip_lines(lines):
  comment_remover = re.compile(r'[\s]*//.*$')
  for i, line in enumerate(lines):
    line = line.strip()
    if m := comment_remover.search(line):
      line = line[:m.start()]
    if not line:
      continue
    yield i+1, line


def _extract_symbols(lines):
  output = {f'R{i}': i for i in range(16)}
  output['SCREEN'] = 0x4000
  output['KBD'] = 0x6000
  output['SP'] = 0
  output['LCL'] = 1
  output['ARG'] = 2
  output['THIS'] = 3
  output['THAT'] = 4
  symbol_location = 0
  for line_no, line in lines:
    if m := _label_re.search(line):
      symbol_name = m.group(1)
      if symbol_name in output:
        raise Error(f'Found duplicate symbol {symbol_name} on line {line_no}')
      output[symbol_name] = symbol_location
      continue
    symbol_location += 1
  return output


def _emit_instructions(lines, symbol_table):
  jmp_mapping = {
      'JGT': 0b001,
      'JEQ': 0b010,
      'JGE': 0b011,
      'JLT': 0b100,
      'JNE': 0b101,
      'JLE': 0b110,
      'JMP': 0b111,
  }
  alu_mapping = {
      '0': 0b101010,
      '1': 0b111111,
      '-1': 0b111010,
      'D': 0b001100,
      'A': 0b110000,
      '!D': 0b001101,
      '!A': 0b110001,
      '-D': 0b001111,
      '-A': 0b110011,
      'D+1': 0b011111,
      'A+1': 0b110111,
      'D-1': 0b001110,
      'A-1': 0b110010,
      'D+A': 0b000010,
      'D-A': 0b010011,
      'A-D': 0b000111,
      'D&A': 0b000000,
      'D|A': 0b010101,
  }
  for key in list(alu_mapping.keys()):
    if 'A' in key:
      new_key = key.replace('A', 'M')
      alu_mapping[new_key] = alu_mapping[key] | 0b1000000
  register_assignment = 16

  for line_no, line in lines:
    if _label_re.match(line):
      continue

    if line.startswith('@'):
      # Parse an 'A' instruction
      line = line[1:]
      if line.isdigit():
        literal_value = int(line, 10)
      else:
        if line not in symbol_table:
          # We assume that the user wants a new location stored.
          symbol_table[line] = register_assignment
          register_assignment += 1
        literal_value = symbol_table[line]
      yield f'0{literal_value:015b}  // @{line}'
      continue

    # Parse a 'C' instruction
    m = re.match(r'(?:(?P<assignment>[^=]+)=)?(?P<op>[^;]+)(?:;(?P<jmp>.*))?', line)
    if not m:
      raise Error(f'Failed to parse line {line!r} line no {line_no}')
    assignment, op, jmp = m.groups()

    assignment_bits, alu_bits, jump_bits = 0, 0, 0
    if assignment:
      if 'A' in assignment:
        assignment_bits |= 0b100
      if 'M' in assignment:
        assignment_bits |= 0b001
      if 'D' in assignment:
        assignment_bits |= 0b010
    if op not in alu_mapping:
      raise Error(f'Failed to parse alu op {line!r} line no {line_no}')
    alu_bits = alu_mapping[op]
    if jmp:
      if jmp not in jmp_mapping:
        raise Error(f'Failed to parse jmp {line!r} line no {line_no}')
      jump_bits = jmp_mapping[jmp]

    yield f'111{assignment_bits:03b}{alu_bits:07b}{jump_bits:03b}  // {line}'


def main(argv):
  if len(argv) != 2:
    raise app.UsageError('Expected exactly 1 argument')
  _, filename, = argv

  lines = []
  with open(filename, 'r') as f:
    for line_no, line in _strip_lines(f):
      lines.append((line_no, line))

  symbols = _extract_symbols(lines)
  for line in _emit_instructions(lines, symbols):
    print(line)


if __name__ == '__main__':
  app.run(main)
