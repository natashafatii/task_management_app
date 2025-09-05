class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  // Task title validation
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }

    if (value.length < 3) {
      return 'Title must be at least 3 characters long';
    }

    if (value.length > 100) {
      return 'Title cannot exceed 100 characters';
    }

    return null;
  }

  // Task description validation - MADE OPTIONAL
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Description is now optional
    }

    if (value.length > 500) {
      return 'Description cannot exceed 500 characters';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return null; // Empty is handled by required validator
    }

    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Future date validation (date should not be in the past)
  static String? validateFutureDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();

      if (date.isBefore(DateTime(now.year, now.month, now.day))) {
        return 'Date cannot be in the past';
      }

      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Number validation
  static String? validateNumber(String? value, {String fieldName = 'Number'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value, {String fieldName = 'Number'}) {
    final numberError = validateNumber(value, fieldName: fieldName);
    if (numberError != null) {
      return numberError;
    }

    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
        r'^(https?:\/\/)?' // http:// or https://
        r'(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,})' // domain
        r'(:[0-9]{1,5})?' // port
        r'(\/[^\s]*)?$' // path
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Multiple validators
  static String? validateMultiple(List<String? Function()> validators) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  // Conditional validation
  static String? validateCondition(bool condition, String errorMessage) {
    if (!condition) {
      return errorMessage;
    }
    return null;
  }
}

// Extension methods for easier validation
extension StringValidation on String {
  bool get isEmail => Validators.validateEmail(this) == null;
  bool get isStrongPassword => Validators.validatePassword(this) == null;
  bool get isValidTitle => Validators.validateTitle(this) == null;
  bool get isValidDescription => Validators.validateDescription(this) == null;
}

// Example usage in a TextFormField:
/*
TextFormField(
  validator: Validators.validateTitle,
  decoration: InputDecoration(labelText: 'Task Title'),
)
*/

// Example usage with multiple validators:
/*
TextFormField(
  validator: (value) => Validators.validateMultiple([
    () => Validators.validateRequired(value, fieldName: 'Title'),
    () => Validators.validateMinLength(value, 3, fieldName: 'Title'),
    () => Validators.validateMaxLength(value, 100, fieldName: 'Title'),
  ]),
)
*/