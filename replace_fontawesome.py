import os
import glob
import re

mapping = {
    'Icons.fitness_center_rounded': 'FontAwesomeIcons.dumbbell',
    'Icons.water_drop_rounded': 'FontAwesomeIcons.droplet',
    'Icons.nightlight_round': 'FontAwesomeIcons.moon',
    'Icons.mood_rounded': 'FontAwesomeIcons.faceSmile',
    'Icons.directions_walk_rounded': 'FontAwesomeIcons.shoePrints',
    'Icons.monitor_weight_rounded': 'FontAwesomeIcons.scaleBalanced',
    'Icons.local_fire_department_rounded': 'FontAwesomeIcons.fire',
    'Icons.check_box_rounded': 'FontAwesomeIcons.squareCheck',
    'Icons.check_rounded': 'FontAwesomeIcons.check',
    'Icons.bar_chart_rounded': 'FontAwesomeIcons.chartBar',
    'Icons.auto_awesome_rounded': 'FontAwesomeIcons.wandMagicSparkles',
    'Icons.refresh_rounded': 'FontAwesomeIcons.arrowsRotate',
    'Icons.add_rounded': 'FontAwesomeIcons.plus',
    'Icons.more_vert_rounded': 'FontAwesomeIcons.ellipsisVertical',
    'Icons.edit_rounded': 'FontAwesomeIcons.pen',
    'Icons.delete_rounded': 'FontAwesomeIcons.trash',
    'Icons.timer_rounded': 'FontAwesomeIcons.stopwatch',
    'Icons.article_rounded': 'FontAwesomeIcons.fileLines',
    'Icons.star_rounded': 'FontAwesomeIcons.star',
    'Icons.close_rounded': 'FontAwesomeIcons.xmark',
    'Icons.arrow_upward_rounded': 'FontAwesomeIcons.arrowUp',
    'Icons.arrow_downward_rounded': 'FontAwesomeIcons.arrowDown',
    'Icons.adjust_rounded': 'FontAwesomeIcons.bullseye',
    'Icons.remove_rounded': 'FontAwesomeIcons.minus',
    'Icons.camera_alt_rounded': 'FontAwesomeIcons.camera',
    'Icons.settings_rounded': 'FontAwesomeIcons.gear',
    'Icons.directions_run_rounded': 'FontAwesomeIcons.personRunning',
    'Icons.flag_rounded': 'FontAwesomeIcons.flag',
    'Icons.warning_rounded': 'FontAwesomeIcons.triangleExclamation',
    'Icons.lock_rounded': 'FontAwesomeIcons.lock',
    'Icons.verified_user_rounded': 'FontAwesomeIcons.shieldHalved',
    'Icons.grid_view_rounded': 'FontAwesomeIcons.borderAll',
    'Icons.home_rounded': 'FontAwesomeIcons.house',
    'Icons.chevron_right_rounded': 'FontAwesomeIcons.chevronRight',
    'Icons.chevron_left_rounded': 'FontAwesomeIcons.chevronLeft',
    'Icons.favorite_rounded': 'FontAwesomeIcons.heart',
    'Icons.workspace_premium_rounded': 'FontAwesomeIcons.crown',
    'Icons.info_rounded': 'FontAwesomeIcons.circleInfo',
    'Icons.notifications_rounded': 'FontAwesomeIcons.bell',
    'Icons.email_rounded': 'FontAwesomeIcons.envelope',
    'Icons.person_rounded': 'FontAwesomeIcons.user',
    'Icons.logout_rounded': 'FontAwesomeIcons.arrowRightFromBracket',
    'Icons.search_rounded': 'FontAwesomeIcons.magnifyingGlass',
    'Icons.play_arrow_rounded': 'FontAwesomeIcons.play',
    'Icons.pause_rounded': 'FontAwesomeIcons.pause',
    'Icons.emoji_events_rounded': 'FontAwesomeIcons.trophy',
    'Icons.group_rounded': 'FontAwesomeIcons.users',
    'Icons.card_giftcard_rounded': 'FontAwesomeIcons.gift',
    'Icons.wb_sunny_rounded': 'FontAwesomeIcons.sun',
    'Icons.air_rounded': 'FontAwesomeIcons.wind',
    'Icons.visibility_rounded': 'FontAwesomeIcons.eye',
    'Icons.visibility_off_rounded': 'FontAwesomeIcons.eyeSlash',
    'Icons.arrow_forward_rounded': 'FontAwesomeIcons.arrowRight',
    'Icons.help_outline_rounded': 'FontAwesomeIcons.circleQuestion',
    'Icons.pie_chart_rounded': 'FontAwesomeIcons.chartPie',
    'Icons.restaurant_rounded': 'FontAwesomeIcons.utensils',
    'Icons.error_outline_rounded': 'FontAwesomeIcons.circleExclamation',
    'Icons.arrow_back_rounded': 'FontAwesomeIcons.arrowLeft',
    'Icons.smart_toy_rounded': 'FontAwesomeIcons.robot',
    'Icons.send_rounded': 'FontAwesomeIcons.paperPlane',
    'Icons.eco_rounded': 'FontAwesomeIcons.leaf',
    'Icons.calendar_month_rounded': 'FontAwesomeIcons.calendar',
    'Icons.kebab_dining_rounded': 'FontAwesomeIcons.burger',
    'Icons.coffee_rounded': 'FontAwesomeIcons.mugHot',
    'Icons.energy_savings_leaf_rounded': 'FontAwesomeIcons.leaf',
    'Icons.fastfood_rounded': 'FontAwesomeIcons.appleWhole',
    'Icons.restaurant_menu_rounded': 'FontAwesomeIcons.utensils',
    'Icons.celebration_rounded': 'FontAwesomeIcons.champagneGlasses',
    'Icons.build_rounded': 'FontAwesomeIcons.wrench',
    'Icons.message_rounded': 'FontAwesomeIcons.message',
    'Icons.upload_rounded': 'FontAwesomeIcons.upload',
    'Icons.block_rounded': 'FontAwesomeIcons.ban',
    'Icons.restore_rounded': 'FontAwesomeIcons.rotateLeft',
    'Icons.straighten_rounded': 'FontAwesomeIcons.ruler',
    'Icons.headphones_rounded': 'FontAwesomeIcons.headphones',
    'Icons.share_rounded': 'FontAwesomeIcons.shareNodes',
    'Icons.security_rounded': 'FontAwesomeIcons.shield',
    'Icons.download_rounded': 'FontAwesomeIcons.download',
}

files = glob.glob('d:/New folder/Applications/ufit_v2_complete/ufit_v2/lib/**/*.dart', recursive=True)

import_statement = "import 'package:font_awesome_flutter/font_awesome_flutter.dart';\n"

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    modified = False
    
    for mat_icon, fa_icon in mapping.items():
        if mat_icon in content:
            content = content.replace(mat_icon, fa_icon)
            modified = True
            
    if modified:
        # Check if import exists
        if "package:font_awesome_flutter/font_awesome_flutter.dart" not in content:
            # Add import after the first import
            import_match = re.search(r'import .*;', content)
            if import_match:
                end_pos = import_match.end()
                content = content[:end_pos] + '\n' + import_statement + content[end_pos:]
            else:
                content = import_statement + content
                
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)

print("FontAwesome migration complete!")
