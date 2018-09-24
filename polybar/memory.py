#!/usr/bin/python3

import os

class MemInfo():
    def __init__(self, file_path):
        self.info = self.load(file_path)

    def load(self, file_path):
        if not os.path.exists(file_path):
            return {}
        with open(file_path, 'r') as mem_info:
            return dict(
                    [line.strip().replace(':', '').split()[0:2]
                        for line in mem_info.readlines()]
                    )

    def is_loaded(self):
        if self.info:
            return True
        else:
            return False

    def retrieve(self, target):
        return int(self.info[target])

    def get_mem_total(self):
        return self.retrieve('MemTotal')

    def get_mem_free(self):
        return self.retrieve('MemFree')

    def get_buffers(self):
        return self.retrieve('Buffers')

    def get_cached(self):
        return self.retrieve('Cached')

    # key error
    def get_mem_used(self):
        return self.get_mem_total() \
                - self.get_mem_free() \
                - self.get_buffers() \
                - self.get_cached()

# index error
def convert(size, cnt):
    if size < 1024 ** (cnt+1):
        return f'{size / 1024 ** cnt:.1f}{units[cnt]}'
    return convert(size, cnt+1)

def main():
    mem_info = MemInfo('/proc/meminfo')
    if not mem_info.is_loaded():
        return
    used = mem_info.get_mem_used()
    rate = used / mem_info.get_mem_total() * 100
    print('%{F#c0c5ce}%{u#c0c5ce}', f'{icon} {convert(used, 0)} : {rate:.1f}%')


icon = ''
units = ['kB', 'MB', 'GB', 'TB']

if __name__ == '__main__':
    main()
