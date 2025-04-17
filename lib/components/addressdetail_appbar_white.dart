import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/custom_backbutton_white.dart';

class AddressdetailAppbarWhite extends StatelessWidget {
  final String addressId;
  final String? thumbnailUrl; // URL for the thumbnail image
  final Color? iconColor;
  final String label;
  final double titleSize;
  final double leftPadding; // Add left padding parameter
  final Function(String addressId)? onDelete; // Callback for delete action
  final Function(String addressId)? onEdit; // Callback for edit action

  const AddressdetailAppbarWhite({
    super.key,
    required this.addressId,
    this.thumbnailUrl, // Initialize thumbnail URL
    this.iconColor,
    required this.label,
    this.titleSize = 24,
    this.leftPadding = 30, // Default value for left padding
    this.onDelete, // Initialize the delete callback
    this.onEdit, // Initialize the edit callback
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      leading: CustomBackButtonWhite(
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Padding(
        padding: EdgeInsets.only(
            top: 10.0, left: leftPadding), // Use the editable left padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display the thumbnail image or a default icon
            thumbnailUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(thumbnailUrl!),
                    radius: 20,
                  )
                : Icon(
                    Icons.location_on,
                    color: iconColor,
                    size: 30,
                  ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[200]),
              onSelected: (value) {
                if (value == 'edit') {
                  if (onEdit != null) {
                    onEdit!(addressId); // Call the edit callback
                  }
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(context, addressId);
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
          ],
        ),
      ),
    );
  }

  // Function to show a confirmation dialog for deletion
  void _showDeleteConfirmationDialog(BuildContext context, String addressId) {
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
                  onDelete!(addressId); // Call the delete callback
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
