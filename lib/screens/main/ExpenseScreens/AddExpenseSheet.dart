import 'package:flutter/material.dart';

import '../../../widgets/CustomeInput.dart';

void showCustomFormModal(BuildContext context) {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Expense", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CustomInputField(label: "Expense Title", hintText: "John", controller: firstNameController),
            CustomInputField(label: "Amount", hintText: "Doe", controller: lastNameController),

            CustomInputField(
              label: "Date",
              hintText: "Select your birth date",
              controller: dobController,
              readOnly: true,
              icon: Icons.calendar_today,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
                }
              },
            ),
            CustomInputField(label: "Category", hintText: "1234567890", controller: phoneController, icon: Icons.phone),
            CustomInputField(label: "Payer", hintText: "example@mail.com", controller: emailController, icon: Icons.email),
            CustomInputField(label: "Split Among", hintText: "Something...", controller: descriptionController),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // handle submission here
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C6EF5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 16,color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
