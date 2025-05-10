# Multi-Destination ZIP Extractor

A simple command-line tool written in Dart that allows you to extract multiple ZIP files to multiple destination folders simultaneously.

## Features

- Specify a custom source directory containing ZIP files
- Extract to multiple destination directories in one operation
- Maintains directory structure within each ZIP file
- Interactive command-line interface with clear prompts
- Shows extraction progress and results

## Requirements

- Dart SDK (version 2.12.0 or higher recommended)
- The `archive` package for handling ZIP files

## Installation

1. Make sure you have the [Dart SDK](https://dart.dev/get-dart) installed
2. Clone this repository or download the source code
3. Navigate to the project directory
4. Run `dart pub get` to install dependencies

## Usage

1. Run the program:
   ```
   dart run extrator.dart
   ```

2. When prompted, enter the source folder containing your ZIP files
   ```
   Enter source folder path for ZIP files: C:/Downloads/my_zips
   ```

3. The program will display all found ZIP files in the specified directory:
   ```
   Searching for ZIP files in C:/Downloads/my_zips...
   Found 3 ZIP file(s).
   - project1.zip
   - project2.zip
   - documents.zip
   ```

4. Enter one or more destination folders where you want to extract the ZIP files:
   ```
   Now, let's set up your destination folders:
   Enter destination folder path (or press Enter when done): D:/Projects
   Destination added: D:/Projects
   Enter another destination folder path (or press Enter when done): E:/Backup
   Destination added: E:/Backup
   Enter another destination folder path (or press Enter when done): 
   ```

5. Press Enter when you're done adding destinations

6. The program will extract each ZIP file to all specified destinations and show progress:
   ```
   Selected destinations:
   1. D:/Projects
   2. E:/Backup
   
   Extracted: C:/Downloads/my_zips/project1.zip → D:/Projects/project1
   Extracted: C:/Downloads/my_zips/project1.zip → E:/Backup/project1
   Extracted: C:/Downloads/my_zips/project2.zip → D:/Projects/project2
   Extracted: C:/Downloads/my_zips/project2.zip → E:/Backup/project2
   Extracted: C:/Downloads/my_zips/documents.zip → D:/Projects/documents
   Extracted: C:/Downloads/my_zips/documents.zip → E:/Backup/documents
   
   ✅ All ZIPs extracted to: 
   - D:/Projects
   - E:/Backup
   ```

## Project Structure

```
multi_destination_zip_extractor/
├── bin/
│   └── extrator.dart     # Main application code
├── pubspec.yaml      # Dart dependencies
└── README.md         # This file
```

## Dependencies

This project requires the following Dart package:
- `archive`: For handling ZIP file decompression

The `pubspec.yaml` file should include:

```yaml
name: multi_destination_zip_extractor
description: Tool to extract ZIP files to multiple destinations
version: 1.0.0

environment:
  sdk: '>=2.12.0 <3.0.0'

dependencies:
  archive: ^3.3.0
```

## Error Handling

The program includes basic error handling for:
- Non-existent source directories
- Empty input
- No ZIP files found in the source directory

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Troubleshooting

**Q: The program isn't finding my ZIP files**  
A: Make sure you're entering the correct full path to the directory containing your ZIP files and that they have the `.zip` extension (case insensitive).

**Q: I'm getting permission errors**  
A: Make sure you have read permissions for the source directory and write permissions for the destination directories.

**Q: The extraction is taking a long time**  
A: Large ZIP files or extracting to multiple destinations can take some time. The program will show progress for each extraction.