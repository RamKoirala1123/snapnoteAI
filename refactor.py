import glob

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content
    # Replace AppScaffold with KScaffold
    new_content = new_content.replace('AppScaffold', 'KScaffold')
    new_content = new_content.replace('AppCard', 'KContainer')
    new_content = new_content.replace('app_scaffold.dart', 'k_components.dart')
    
    # Simple replacement for Scaffold to KScaffold if not already KScaffold
    new_content = new_content.replace(' Scaffold(', ' KScaffold(')
    new_content = new_content.replace('return Scaffold(', 'return KScaffold(')
    
    # Replace ElevatedButtons to KButton.primary
    new_content = new_content.replace('ElevatedButton.icon(', 'KButton.primary(')
    # The button properties need to be manually fixed because ElevatedButton.icon takes 'label' but my KButton also takes label, wait my KButton takes child/label/icon.
    # It's better to just fix dashboard_view manually for the button since it's the only one I saw easily.
    
    # Add import if KScaffold is used but not imported
    if 'KScaffold(' in new_content and 'k_components.dart' not in new_content and 'k_components.dart' not in filepath:
        import_idx = new_content.rfind('import ')
        if import_idx != -1:
            end_of_line = new_content.find('\n', import_idx)
            
            # naive relative path calc
            prefix = '../widgets/' if 'views' in filepath or 'layout' in filepath else './ui/widgets/'
            if 'main.dart' in filepath:
                prefix = 'ui/widgets/'
            import_statement = f"\nimport '{prefix}k_components.dart';"
            new_content = new_content[:end_of_line] + import_statement + new_content[end_of_line:]
    
    if content != new_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print('Updated', filepath)
