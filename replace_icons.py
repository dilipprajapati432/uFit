import os
import glob
import re

mapping = {
    'LucideIcons.dumbbell': 'Icons.fitness_center_rounded',
    'LucideIcons.droplet': 'Icons.water_drop_rounded',
    'LucideIcons.moon': 'Icons.nightlight_round',
    'LucideIcons.smile': 'Icons.mood_rounded',
    'LucideIcons.footprints': 'Icons.directions_walk_rounded',
    'LucideIcons.scale': 'Icons.monitor_weight_rounded',
    'LucideIcons.flame': 'Icons.local_fire_department_rounded',
    'LucideIcons.checkSquare': 'Icons.check_box_rounded',
    'LucideIcons.check': 'Icons.check_rounded',
    'LucideIcons.barChart2': 'Icons.bar_chart_rounded',
    'LucideIcons.sparkles': 'Icons.auto_awesome_rounded',
    'LucideIcons.refreshCw': 'Icons.refresh_rounded',
    'LucideIcons.plus': 'Icons.add_rounded',
    'LucideIcons.moreVertical': 'Icons.more_vert_rounded',
    'LucideIcons.pencil': 'Icons.edit_rounded',
    'LucideIcons.trash2': 'Icons.delete_rounded',
    'LucideIcons.timer': 'Icons.timer_rounded',
    'LucideIcons.fileText': 'Icons.article_rounded',
    'LucideIcons.star': 'Icons.star_rounded',
    'LucideIcons.x': 'Icons.close_rounded',
    'LucideIcons.arrowUp': 'Icons.arrow_upward_rounded',
    'LucideIcons.arrowDown': 'Icons.arrow_downward_rounded',
    'LucideIcons.target': 'Icons.adjust_rounded',
    'LucideIcons.minus': 'Icons.remove_rounded',
    'LucideIcons.camera': 'Icons.camera_alt_rounded',
    'LucideIcons.settings': 'Icons.settings_rounded',
    'LucideIcons.activity': 'Icons.directions_run_rounded',
    'LucideIcons.flag': 'Icons.flag_rounded',
    'LucideIcons.alertTriangle': 'Icons.warning_rounded',
    'LucideIcons.lock': 'Icons.lock_rounded',
    'LucideIcons.shieldCheck': 'Icons.verified_user_rounded',
    'LucideIcons.droplets': 'Icons.water_drop_rounded',
    'LucideIcons.layoutGrid': 'Icons.grid_view_rounded',
    'LucideIcons.home': 'Icons.home_rounded',
    'LucideIcons.chevronRight': 'Icons.chevron_right_rounded',
    'LucideIcons.chevronLeft': 'Icons.chevron_left_rounded',
    'LucideIcons.heart': 'Icons.favorite_rounded',
    'LucideIcons.crown': 'Icons.workspace_premium_rounded',
    'LucideIcons.info': 'Icons.info_rounded',
    'LucideIcons.bell': 'Icons.notifications_rounded',
    'LucideIcons.mail': 'Icons.email_rounded',
    'LucideIcons.user': 'Icons.person_rounded',
    'LucideIcons.logOut': 'Icons.logout_rounded',
    'LucideIcons.search': 'Icons.search_rounded',
    'LucideIcons.play': 'Icons.play_arrow_rounded',
    'LucideIcons.pause': 'Icons.pause_rounded',
    'LucideIcons.award': 'Icons.emoji_events_rounded',
    'LucideIcons.users': 'Icons.group_rounded',
    'LucideIcons.gift': 'Icons.card_giftcard_rounded',
    'LucideIcons.sun': 'Icons.wb_sunny_rounded',
    'LucideIcons.wind': 'Icons.air_rounded',
    'LucideIcons.eye': 'Icons.visibility_rounded',
    'LucideIcons.eyeOff': 'Icons.visibility_off_rounded',
    'LucideIcons.arrowRight': 'Icons.arrow_forward_rounded',
    'LucideIcons.helpCircle': 'Icons.help_outline_rounded',
    'LucideIcons.pieChart': 'Icons.pie_chart_rounded',
    'LucideIcons.utensils': 'Icons.restaurant_rounded',
    'LucideIcons.alertCircle': 'Icons.error_outline_rounded',
    'LucideIcons.arrowLeft': 'Icons.arrow_back_rounded',
    'LucideIcons.barChart': 'Icons.bar_chart_rounded',
    'LucideIcons.bot': 'Icons.smart_toy_rounded',
    'LucideIcons.send': 'Icons.send_rounded',
    'LucideIcons.sprout': 'Icons.eco_rounded',
    'LucideIcons.calendar': 'Icons.calendar_month_rounded',
    'LucideIcons.beef': 'Icons.kebab_dining_rounded',
    'LucideIcons.coffee': 'Icons.coffee_rounded',
    'LucideIcons.leaf': 'Icons.energy_savings_leaf_rounded',
    'LucideIcons.apple': 'Icons.fastfood_rounded',
    'LucideIcons.utensilsCrossed': 'Icons.restaurant_menu_rounded',
    'LucideIcons.partyPopper': 'Icons.celebration_rounded',
    'LucideIcons.wrench': 'Icons.build_rounded',
    'LucideIcons.messageCircle': 'Icons.message_rounded',
    'LucideIcons.upload': 'Icons.upload_rounded',
    'LucideIcons.ban': 'Icons.block_rounded',
    'LucideIcons.rotateCcw': 'Icons.restore_rounded',
    'LucideIcons.ruler': 'Icons.straighten_rounded',
    'LucideIcons.headphones': 'Icons.headphones_rounded',
    'LucideIcons.share2': 'Icons.share_rounded',
    'LucideIcons.shield': 'Icons.security_rounded',
    'LucideIcons.download': 'Icons.download_rounded',
}

files = glob.glob('d:/New folder/Applications/ufit_v2_complete/ufit_v2/lib/**/*.dart', recursive=True)

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Replace the imports
    content = content.replace("import 'package:lucide_icons/lucide_icons.dart';", "")
    
    for lucide, material in mapping.items():
        content = content.replace(lucide, material)
        
    remaining = re.findall(r'LucideIcons\.[a-zA-Z0-9_]+', content)
    if remaining:
        print(f"Remaining in {file}: {set(remaining)}")
        for r in set(remaining):
            content = content.replace(r, "Icons.circle")
            
    if content != original_content:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
print("Done!")
