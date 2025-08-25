import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerWidget extends StatefulWidget {
  final Function(PlatformFile) onUpload; // Callback

  const FilePickerWidget({Key? key, required this.onUpload}) : super(key: key);

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  List<PlatformFile>? files;

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        files = result.files;
      });
    }
  }

  void uploadFile() {
    if (files != null && files!.isNotEmpty) {
      widget.onUpload(files!.first); // Upload the first file (single selection)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected to upload')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: pickFiles,
          icon: const Icon(Icons.attach_file),
          label: const Text('Pick File'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 16),
        if (files != null && files!.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: files!.length,
              itemBuilder: (context, index) {
                final file = files![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(file.name),
                    subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          files!.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No files selected',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        const SizedBox(height: 16),
        // Upload Button at the bottom
        ElevatedButton.icon(
          onPressed: uploadFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}
