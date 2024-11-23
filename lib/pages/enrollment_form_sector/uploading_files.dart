import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadingFiles extends StatefulWidget {
    final double spacing;
  final Function(List<PlatformFile>) onFilesSelected;

  const UploadingFiles({required this.onFilesSelected, required this.spacing, Key? key}) : super(key: key);

  @override
  State<UploadingFiles> createState() => _UploadingFilesState();
}

class _UploadingFilesState extends State<UploadingFiles> {
  final List<PlatformFile> _selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });

      // Pass the selected files to the parent widget
      widget.onFilesSelected(_selectedFiles);
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });

    // Update the parent widget with the updated file list
    widget.onFilesSelected(_selectedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Note: Please attach files for Form 137, Birth Certificate, etc.'),
        Container(
        height: 25,
        width: 150,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.grey.shade300),
                    elevation: MaterialStateProperty.all<double>(5),
                      shape:
                      MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
          onPressed: _pickFiles,
          child: const Text('Attach Files', style: TextStyle(color: Colors.black),),
        ),
        ),
        if (_selectedFiles.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _selectedFiles.map((file) {
        return Container(
          width: 300, // Set a specific width for the container
          height: 50, // Set a specific height for the container
          margin: const EdgeInsets.only(top: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  file.name,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                onPressed: () => _removeFile(file),
                tooltip: 'Remove file',
              ),
            ],
          ),
        );
      }).toList(),
    ),
  ),

      ],
    );
  }
}