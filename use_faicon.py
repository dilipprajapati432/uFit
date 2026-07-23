import glob
import re

files = glob.glob('d:/New folder/Applications/ufit_v2_complete/ufit_v2/lib/**/*.dart', recursive=True)

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Replace Icon(FontAwesomeIcons with FaIcon(FontAwesomeIcons
    content = content.replace("Icon(FontAwesomeIcons", "FaIcon(FontAwesomeIcons")
    
    # In common_widgets.dart GradientIcon:
    if "GradientIcon" in content and "Icon(" in content:
        content = content.replace("Icon(\n        icon,\n        size: size,\n        color: Colors.white,\n      )", "FaIcon(\n        icon,\n        size: size,\n        color: Colors.white,\n      )")
    
    # If the user wants exact original, maybe they don't want GlowIcon? 
    # I'll leave GlowIcon but use FaIcon inside it.
        
    if content != original_content:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)

print("Replaced Icon with FaIcon.")
