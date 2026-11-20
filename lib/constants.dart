import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

const productDemoImg1 = "https://i.imgur.com/CGCyp1d.png";
const productDemoImg2 = "https://i.imgur.com/AkzWQuJ.png";
const productDemoImg3 = "https://i.imgur.com/J7mGZ12.png";
const productDemoImg4 = "https://i.imgur.com/q9oF9Yq.png";
const productDemoImg5 = "https://i.imgur.com/MsppAcx.png";
const productDemoImg6 = "https://i.imgur.com/JfyZlnO.png";

const grandisExtendedFont = "Grandis Extended";

// SAM CARD luxury gold and dark colors
const Color primaryColor = Color(0xFFD4AF37);
const Color samCardGold = Color(0xFFD4AF37);
const Color samCardGoldLight = Color(0xFFF1D57A);
const Color samCardGoldDark = Color(0xFFA98621);

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFFD4AF37, <int, Color>{
  50: Color(0xFFFFF9E7),
  100: Color(0xFFF8ECC1),
  200: Color(0xFFF1D57A),
  300: Color(0xFFE5C45A),
  400: Color(0xFFDDBD4A),
  500: Color(0xFFD4AF37),
  600: Color(0xFFC59F2F),
  700: Color(0xFFA98621),
  800: Color(0xFF8C6D1C),
  900: Color(0xFF665019),
});

const Color blackColor = Color(0xFF101114);
const Color blackColor80 = Color(0xFF292A2F);
const Color blackColor60 = Color(0xFF44464E);
const Color blackColor40 = Color(0xFF676A74);
const Color blackColor20 = Color(0xFF9A9DA5);
const Color blackColor10 = Color(0xFFC2C4C9);
const Color blackColor5 = Color(0xFFE0E1E3);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFE0E0E0);
const Color whileColor60 = Color(0xFFCCCCCC);
const Color whileColor40 = Color(0xFFB0B0B0);
const Color whileColor20 = Color(0xFF777777);
const Color whileColor10 = Color(0xFF404040);
const Color whileColor5 = Color(0xFF252525);

const Color greyColor = Color(0xFFA7A7A7);
const Color lightGreyColor = Color(0xFFF4F4F4);
const Color darkGreyColor = Color(0xFF1A1B20);

const Color purpleColor = Color(0xFFD4AF37);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  PatternValidator(
    r'(?=.*?[#?!@$%^&*-])',
    errorText: 'passwords must have at least one special character',
  ),
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

const pasNotMatchErrorText = "passwords do not match";
