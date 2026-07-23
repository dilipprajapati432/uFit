import glob
import re

files = glob.glob('d:/New folder/Applications/ufit_v2_complete/ufit_v2/lib/**/*.dart', recursive=True)

def replace_size(m):
    prefix = m.group(1)
    size = int(m.group(2))
    new_size = int(size * 0.8)
    return f"FaIcon({prefix}size: {new_size}{m.group(3)})"

def add_size(m):
    inner = m.group(1)
    if 'size:' not in inner:
        return f"FaIcon({inner}, size: 19)"
    return m.group(0)

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # 1. Scale explicit sizes inside FaIcon
    content = re.sub(r'FaIcon\(([^)]*?)size:\s*(\d+)([^)]*?)\)', replace_size, content)
    
    # 2. Add size: 19 to FaIcons that don't have size specified
    content = re.sub(r'FaIcon\(([^)]*?)\)', add_size, content)
    
    if content != original:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)

print("Sizes reduced")
