import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils.dart';

class DropdownWidget extends StatefulWidget {
  final String username;

  const DropdownWidget({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  late String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = 'logout';
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          widget.username,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme
                .of(context)
                .colorScheme
                .primary,
          ),
        ),
        items: [
          DropdownMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
              ],
            ),
          ),
        ],
        onChanged: (String? value) {
          setState(() {
            selectedValue = value;
            if (value == 'logout') {
              logout(context);
            }
          });
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: 140,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
      ),
    );
  }
}