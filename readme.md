# 🗜️ ZIP Extractor Tool

A powerful, user-friendly command-line tool to extract multiple ZIP files from a source directory to multiple destination directories simultaneously.

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

- 🚀 **Batch Extraction** - Extract all ZIP files from a directory at once
- 🎯 **Multiple Destinations** - Extract to multiple locations simultaneously
- 📁 **Auto Directory Creation** - Creates destination folders if they don't exist
- 🛡️ **Error Handling** - Gracefully handles corrupted or invalid ZIP files
- 📊 **Progress Tracking** - Shows detailed progress and file information
- 🎨 **User-Friendly Interface** - Clear messages and helpful guidance
- 💾 **Preserve Structure** - Maintains folder structure within ZIP files
- 📈 **File Size Display** - Shows ZIP file sizes in human-readable format

## 🚀 Quick Start

### Download & Run (Easiest)

1. **Download** the executable from the [Releases](../../releases) page
2. **Run** the executable:
   - **Windows**: Double-click `zip_extractor.exe` or run from Command Prompt
   - **Linux/macOS**: Run `./zip_extractor` in terminal

### Command Line Usage

```bash
# Run the tool
./extractor

# Show help
./extractor --help
```

## 📖 How to Use

### Step-by-Step Guide

1. **Start the tool** by running the executable
2. **Enter source path** - The folder containing your ZIP files
   ```
   Enter source folder path for ZIP files: C:\Downloads\ZipFiles
   ```
3. **Add destinations** - Enter one or more destination folders
   ```
   Enter destination folder path: C:\Extracted
   Enter another destination path (or press Enter to continue): D:\Backup\Extracted
   Enter another destination path (or press Enter to continue): [Press Enter]
   ```
4. **Watch the magic happen** - The tool will extract all ZIP files to all destinations

### Example Workflow

```
🗜️  Welcome to ZIP Extractor Tool!
========================================

Enter source folder path for ZIP files: /home/user/downloads
✅ Source folder found: /home/user/downloads

📂 Setting up destination folders:
Enter destination folder path: /home/user/extracted
✅ Destination added: /home/user/extracted
Enter another destination path (or press Enter to continue): /backup/extracted
✅ Destination added: /backup/extracted
Enter another destination path (or press Enter to continue): 

🔍 Searching for ZIP files in /home/user/downloads...
✅ Found 3 ZIP file(s):
  📦 project1.zip (2.5 MB)
  📦 documents.zip (1.2 MB)
  📦 photos.zip (15.3 MB)

🚀 Starting extraction process...

📦 Processing: project1.zip
  📄 Archive contains 25 file(s)
  ✅ Extracted 25 file(s) to: /home/user/extracted/project1
  ✅ Extracted 25 file(s) to: /backup/extracted/project1

🎉 EXTRACTION COMPLETE!
```

## 💻 System Requirements

- **Operating System**: Windows 10+, Linux, or macOS
- **Memory**: 100MB RAM minimum
- **Storage**: 50MB free space for the tool
- **Permissions**: Read access to source directory, write access to destination directories

## 🛠️ Installation Options

### Option 1: Download Executable (Recommended)
- Download from [Releases](../../releases) page
- No installation required - just run!

### Option 2: Build from Source
If you have Dart SDK installed:

```bash
# Clone the repository
git clone https://github.com/Qharny/zip_extractor.git
cd zip-extractor-tool

# Install dependencies
dart pub get

# Build executable
dart compile exe zip_extractor.dart -o zip_extractor.exe
```

## 📚 Help & Documentation

### Command Line Options

| Option | Description |
|--------|-------------|
| `--help`, `-h` | Show detailed help information |

### Getting Help

```bash
./extractor --help
```

This will show:
- Detailed usage instructions
- Feature explanations
- Examples and tips
- Troubleshooting guidance

## 🔧 Troubleshooting

### Common Issues

**"Source folder does not exist"**
- ✅ Check the path is correct
- ✅ Use absolute paths (full path from root)
- ✅ Ensure you have read permissions

**"No ZIP files found"**
- ✅ Verify ZIP files have `.zip` extension
- ✅ Check files aren't corrupted
- ✅ Ensure ZIP files are directly in the source folder

**"Permission denied"**
- ✅ Run as administrator (Windows) or with sudo (Linux/macOS)
- ✅ Check destination folder permissions
- ✅ Ensure antivirus isn't blocking the tool

**"Extraction failed"**
- ✅ ZIP file might be corrupted
- ✅ Check available disk space
- ✅ Verify destination path is valid

### Performance Tips

- **Large ZIP files**: Be patient, large archives take time
- **Many destinations**: Each destination doubles processing time
- **Network drives**: Local drives are faster than network locations
- **Antivirus**: Add tool to antivirus exclusions for better performance

## 🌟 Use Cases

### Personal Use
- 📁 Organizing downloaded ZIP files
- 🎮 Extracting game files to multiple locations
- 📸 Processing photo archives
- 📚 Managing document collections

### Professional Use
- 🏢 IT deployments to multiple servers
- 📊 Data processing workflows
- 🔄 Backup and archival processes
- 👥 Team file distribution

### Development
- 📦 Package distribution
- 🛠️ Build artifact extraction
- 🔧 Environment setup automation
- 📋 Project template deployment

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Report Bugs** - Open an issue with details
2. **Suggest Features** - Share your ideas
3. **Submit Pull Requests** - Help improve the code
4. **Improve Documentation** - Help others understand better

### Development Setup

```bash
# Clone the repository
git clone https://github.com/Qharny/zip_extractor.git
cd zip-extractor-tool

# Install Dart SDK (if not already installed)
# Visit: https://dart.dev/get-dart

# Install dependencies
dart pub get

# Run the tool
dart run extractor.dart
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Dart](https://dart.dev/) programming language
- Uses the [archive](https://pub.dev/packages/archive) package for ZIP handling
- Inspired by the need for efficient batch ZIP extraction

## 📞 Support

- 🐛 **Bug Reports**: [Open an issue](../../issues)
- 💡 **Feature Requests**: [Open an issue](../../issues)
- 📧 **Email**: kabuteymanasseh5@gmail.com
- 💬 **Discussions**: [GitHub Discussions](../../discussions)

## 🚀 What's Next?

Planned features for future versions:
- 🎨 GUI version
- 🔐 Password-protected ZIP support
- 📊 Extraction statistics export
- 🔄 Watch folder mode
- 🎯 Selective file extraction
- 📱 Mobile companion app

---

<div align="center">

**Made with ❤️ for the community**

⭐ **Star this repository if you find it helpful!** ⭐

[Download Latest Release](../../releases) | [Report Issue](../../issues) | [Request Feature](../../issues)

</div>