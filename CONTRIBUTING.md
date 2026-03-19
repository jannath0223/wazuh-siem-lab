# Contributing Guidelines

Thank you for your interest in contributing to this project!

## How to Contribute

### Reporting Issues
If you find a bug or something that doesn't work:
1. Go to the **Issues** tab on GitHub
2. Click **New Issue**
3. Describe what happened and what you expected
4. Include your OS, VirtualBox version, and error message

### Suggesting Improvements
1. Open an Issue with the label `enhancement`
2. Describe your suggestion clearly

### Submitting Code Changes
1. **Fork** this repository
2. **Clone** your fork: `git clone https://github.com/YOUR_USERNAME/wazuh-siem-lab.git`
3. **Create a branch**: `git checkout -b fix/description-of-fix`
4. **Make your changes**
5. **Test** that everything still works
6. **Commit**: `git commit -m "Fix: clear description of what you changed"`
7. **Push**: `git push origin fix/description-of-fix`
8. Open a **Pull Request** on GitHub

## Code Style Guidelines

### Shell Scripts
- Add a header comment explaining what the script does
- Include the target machine (Ubuntu/Kali) in the header
- Add `echo` statements to show progress
- Handle errors gracefully with clear messages

### Markdown Files
- Use clear headings
- Include code blocks with language tags (```bash)
- Keep explanations beginner-friendly
- Test all commands before submitting

## What We Welcome
- Bug fixes
- Clearer explanations
- Additional attack scenarios (educational only)
- Better troubleshooting tips
- Translations to other languages

## What We Don't Accept
- Any content that facilitates real attacks on systems without permission
- Scripts that target real IPs or external systems
- Content that removes safety warnings

## Questions?
Open an Issue and tag it with `question`.
