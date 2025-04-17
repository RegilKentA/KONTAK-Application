import 'package:flutter/material.dart';

class AddressdetailAppbarMain extends StatelessWidget {
  final String addressId;
  final String selectedCity;
  final String? thumbnailUrl; // URL for the thumbnail image
  final Color? iconColor;
  final String label;
  final double titleSize;
  final void Function(String addressId, String selectedCity)?
      onDelete; // Updated callback for delete action
  final void Function(String addressId, String selectedCity)?
      onEdit; // Updated callback for edit action
  final bool isAdmin; // Add this parameter to check if the user is an admin

  const AddressdetailAppbarMain({
    super.key,
    required this.addressId,
    required this.selectedCity,
    this.thumbnailUrl, // Initialize thumbnail URL
    this.iconColor,
    required this.label,
    this.titleSize = 24,
    this.onDelete, // Initialize the delete callback
    this.onEdit, // Initialize the edit callback
    this.isAdmin = false, // Default to false if not provided
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      flexibleSpace: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Thumbnail or default icon
              thumbnailUrl != null
                  ? Image.network(
                      thumbnailUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.location_on,
                      color: iconColor,
                      size: 30,
                    ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      actions: isAdmin
          ? [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[200]),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call(addressId, selectedCity);
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(
                        context, addressId, selectedCity);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            ]
          : [],
    );
  }

  // Function to show a confirmation dialog for deletion
  void _showDeleteConfirmationDialog(
      BuildContext context, String addressId, String selectedCity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this address?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (onDelete != null) {
                  onDelete!(addressId,
                      selectedCity); // Call the delete callback with addressId and selectedCity
                } else {
                  // Fallback logic if onDelete is not provided
                  print("Delete function not provided!");
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
