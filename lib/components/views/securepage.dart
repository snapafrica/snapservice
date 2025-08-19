import 'package:snapservice/common.dart';

class SecureScreen extends StatefulWidget {
  final ValueChanged<String> onConfirm;
  final String placeholder;

  const SecureScreen({
    super.key,
    required this.onConfirm,
    required this.placeholder,
  });

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  String input = "";
  bool isLoading = false;
  final TextEditingController _controller = TextEditingController();

  void _updateInput(String value) {
    if (input.length < 10) {
      setState(() {
        input += value;
        _controller.text = '•' * input.length;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _removeLastDigit() {
    if (input.isNotEmpty) {
      setState(() {
        input = input.substring(0, input.length - 1);
        _controller.text = '•' * input.length;
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _clearInput() {
    setState(() {
      input = "";
      _controller.clear();
    });
    HapticFeedback.heavyImpact();
  }

  void _onConfirm() async {
    if (input.isNotEmpty) {
      setState(() => isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => isLoading = false);
      widget.onConfirm(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d0d0d),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.3),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      _inputField(),
                      const SizedBox(height: 20),
                      _confirmButton(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: _numericKeyboard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: TextField(
        controller: _controller,
        autofocus: true,
        readOnly: true,
        obscureText: true,
        obscuringCharacter: '•',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width > 600 ? 30 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _confirmButton() {
    LinearGradient buttonGradient = const LinearGradient(
      colors: [Color(0xff232526), Color(0xff414345)],
    );

    if (input.isNotEmpty) {
      buttonGradient = const LinearGradient(
        colors: [Color(0xFF0b3d2e), Color(0xFF121212)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return GestureDetector(
      onTap: input.isNotEmpty ? _onConfirm : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 18),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: buttonGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _numericKeyboard() {
    return SizedBox(
      width: double.infinity,
      child: NumericKeyboard(
        onKeyboardTap: _updateInput,
        rightButtonFn: _removeLastDigit,
        rightButtonLongPressFn: _clearInput,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        rightIcon: const Icon(
          Icons.backspace_outlined,
          color: Colors.redAccent,
          size: 30,
        ),
      ),
    );
  }
}
