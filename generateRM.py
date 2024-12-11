#!/usr/bin/python3

import os
import subprocess
import timeit

content = [
  '# 🎄 Advent of Code 2024 🎄',
  'Solutions for [Advent of Code 2024](https://adventofcode.com/2024). This years objective is to learn ZigLang',
  '## Usage',
  '```zig build run -- <day>```',
  '## Solution info for days'
]

dirs = [f'./src/{f}' for f in os.listdir('./src') if os.path.isdir('./src/'+f) and f[0:3] == 'aoc']
emojis = ['👼','🎅','🤶','🧑‍🎄','🧝','🧝‍♂️','🧝‍♀️','👪','🦌','🍪','🥛','🍷','🍴','⛪','🌟','❄️','☃️','⛄','🔥','🎄','🎁','🧦','🔔','🎶','🕯️','🛐','✝️']
dirs.sort(key=lambda s: int(s[9:]))
content.append('| 🎄 | Day | Time | #1 | #2 |')
content.append('| --- | --- | --- | --- | --- |')
subprocess.check_output(['zig', 'build', '-Doptimize=ReleaseFast'])
for i,dir in enumerate(dirs):
    fileName = dir.lower() + "/" + dir.replace("./src/", "") + '.zig'
    time = subprocess.check_output([f'./zig-out/bin/AoC2024', f'{i + 1}', '--time'])
    time = '{:g}'.format(float('{:.{p}g}'.format(float(time)/1000_000, p=2)))
    content.append(f'| [{emojis[i]}](https://adventofcode.com/2024/day/{dir.replace("./src/aoc","")}) | [{dir.replace("./src/aoc", "Day ").capitalize()}]({fileName}) | {time} ms | ✅ | ✅ |')

with open('README.md', 'w') as file:
    file.write('\n'.join(content))