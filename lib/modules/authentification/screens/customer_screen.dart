import 'package:snapservice/common.dart';

class CustomerAgentScreen extends ConsumerStatefulWidget {
  final bool isAgent;

  const CustomerAgentScreen({super.key, required this.isAgent});

  @override
  ConsumerState<CustomerAgentScreen> createState() =>
      _CustomerAgentScreenState();
}

class _CustomerAgentScreenState extends ConsumerState<CustomerAgentScreen> {
  final TextEditingController _controller = TextEditingController();
  String input = "";
  bool _isAgent = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _isAgent = widget.isAgent;
    final phone = ref.read(cartServiceProvider).phone;
    if (!_isAgent && phone != null && phone.isNotEmpty) {
      input = phone;
      _controller.text = phone;
    }
  }

  void _updateInput(String value) {
    if (_isAgent && input.length < 8) {
      setState(() {
        input += value;
        _controller.text = "•" * input.length;
      });
    } else if (!_isAgent && input.length < 10) {
      setState(() {
        input += value;
        _controller.text = input;
      });
    }
    HapticFeedback.lightImpact();
  }

  void _removeLastDigit() {
    if (input.isNotEmpty) {
      setState(() {
        input = input.substring(0, input.length - 1);
        _controller.text = _isAgent ? "•" * input.length : input;
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
    if ((_isAgent && input.length == 8) || (!_isAgent && input.length == 10)) {
      setState(() {
        isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      if (_isAgent) {
        final theme = ref.watch(themeServicesProvider);
        final agentsAsyncValue = ref.read(agentsServicesProvider);
        agentsAsyncValue.when(
          data: (agents) {
            final agentUsing =
                agents
                    .where(
                      (a) =>
                          a.pin.toString().toLowerCase() == input.toLowerCase(),
                    )
                    .firstOrNull;

            if (agentUsing == null) {
              context.showToast(
                'Wrong pin',
                error: true,
                textColor: theme.textIconPrimaryColor,
              );
            } else if (agentUsing.archived) {
              context.showToast(
                'Agent is archived',
                error: true,
                textColor: theme.textIconPrimaryColor,
              );
            } else {
              ref.read(cartServiceProvider.notifier).mainAgent = agentUsing;
              setState(() {
                _controller.clear();
                _isAgent = false;
              });
              context.showToast(
                'PIN verified',
                textColor: theme.textIconPrimaryColor,
              );
            }
          },
          loading: () {
            setState(() {
              isLoading = true;
            });
          },
          error: (error, stackTrace) {
            context.showToast(
              'Failed to load agents',
              error: true,
              textColor: theme.textIconPrimaryColor,
            );
            setState(() {
              isLoading = false;
            });
          },
        );
      } else {
        ref.read(cartServiceProvider.notifier).clientPhone = input;
        context.go('/');
      }

      setState(() => isLoading = false);
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
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _inputField(),
                      const SizedBox(height: 20),
                      _confirmButton(),
                      const SizedBox(height: 20),
                      NumericKeyboard(
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
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width > 600 ? 30 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        cursorColor: Colors.white70,
        decoration: InputDecoration(
          hintText: _isAgent ? 'Enter PIN' : 'Enter phone number',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(_isAgent ? 8 : 10),
        ],
        onChanged: (text) {
          setState(() {
            input = text;
          });
        },
      ),
    );
  }

  Widget _confirmButton() {
    String buttonText = _isAgent ? 'Dial PIN' : 'Dial Phone';
    LinearGradient buttonGradient = const LinearGradient(
      colors: [Color(0xff232526), Color(0xff414345)],
    );

    if ((_isAgent && input.length == 8) || (!_isAgent && input.length == 10)) {
      buttonText = 'Confirm';
      buttonGradient = const LinearGradient(
        colors: [Color(0xFF0b3d2e), Color(0xFF121212)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return GestureDetector(
      onTap:
          (_isAgent && input.length == 8) || (!_isAgent && input.length == 10)
              ? _onConfirm
              : null,
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
                  : Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }
}

typedef KeyboardTapCallback = void Function(String text);

class NumericKeyboard extends StatelessWidget {
  final TextStyle textStyle;
  final Widget? rightIcon;
  final Function()? rightButtonFn;
  final Function()? rightButtonLongPressFn;
  final KeyboardTapCallback onKeyboardTap;

  const NumericKeyboard({
    super.key,
    required this.onKeyboardTap,
    this.textStyle = const TextStyle(color: Colors.white),
    this.rightButtonFn,
    this.rightButtonLongPressFn,
    this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    double buttonSize = MediaQuery.of(context).size.width > 600 ? 80 : 75;
    double spacing = MediaQuery.of(context).size.width > 600 ? 60 : 20;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3'], buttonSize, spacing),
          const SizedBox(height: 8),
          _buildRow(['4', '5', '6'], buttonSize, spacing),
          const SizedBox(height: 8),
          _buildRow(['7', '8', '9'], buttonSize, spacing),
          const SizedBox(height: 8),
          _buildRow(
            ['', '0', rightIcon != null ? 'del' : ''],
            buttonSize,
            spacing,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> values, double buttonSize, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          values.map((value) {
            if (value == '') {
              return SizedBox(width: buttonSize + spacing);
            } else if (value == 'del') {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: _iconButton(buttonSize),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: _calcButton(value, buttonSize),
              );
            }
          }).toList(),
    );
  }

  Widget _calcButton(String value, double size) {
    return GestureDetector(
      onTap: () => onKeyboardTap(value),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
          ],
        ),
        child: Center(
          child: Text(
            value,
            style: textStyle.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(double size) {
    return GestureDetector(
      onTap: rightButtonFn,
      onLongPress: rightButtonLongPressFn,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Center(child: rightIcon),
      ),
    );
  }
}
