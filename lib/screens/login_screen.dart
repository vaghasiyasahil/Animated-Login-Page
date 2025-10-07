import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart' hide LinearGradient, RadialGradient;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  Artboard? _teddyArtboard;
  StateMachineController? stateMachineController;

  // Rive Inputs
  SMITrigger? trigSuccess, trigFail;
  SMIBool? isChecking, isHandUp;
  SMINumber? numLook;

  bool _isChecked = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _formController;
  late AnimationController _riveController;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _formAnimation;
  late Animation<double> _riveAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _riveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create animations
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.elasticOut),
    );

    _riveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _riveController, curve: Curves.easeOutBack),
    );

    // Start animations
    _backgroundController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 300), () {
      _riveController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _formController.forward();
    });

    // Load Rive asset
    rootBundle.load('assets/animations/kochalo_login.riv').then(
          (data) {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;

        stateMachineController =
            StateMachineController.fromArtboard(artboard, "State Machine 1");

        if (stateMachineController != null) {
          artboard.addController(stateMachineController!);

          for (var element in stateMachineController!.inputs) {
            debugPrint("Found input: ${element.name}");

            if (element.name == "trigSuccess") {
              trigSuccess = element as SMITrigger;
            } else if (element.name == "trigFail") {
              trigFail = element as SMITrigger;
            } else if (element.name == "isCheking") {
              isChecking = element as SMIBool;
            } else if (element.name == "isHandUp") {
              isHandUp = element as SMIBool;
            } else if (element.name == "numLook") {
              numLook = element as SMINumber;
            }
          }
        }

        setState(() => _teddyArtboard = artboard);
      },
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _riveController.dispose();
    super.dispose();
  }

  void handleFocus() {
    isChecking?.change(true);
    isHandUp?.change(false);
    numLook?.change(0);
  }

  void handlePasswordFocus() {
    isChecking?.change(false);
    isHandUp?.change(true);
    numLook?.change(0);
  }



  void moveEyeTrack(String val) {
    numLook?.change(val.length.toDouble());
  }

  void login() {
    isHandUp?.change(false);
    isChecking?.change(false);

    if (_emailController.text == "zain@gmail.com" &&
        _passwordController.text == "zain") {
      trigSuccess?.fire();
    } else {
      trigFail?.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  Color.lerp(
                    const Color(0xFF2C1810), // Dark brown
                    const Color(0xFF3D2817), // Slightly lighter brown
                    _backgroundAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF1A1A1A), // Dark gray
                    const Color(0xFF2A2A2A), // Lighter gray
                    _backgroundAnimation.value,
                  )!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _riveAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 0.8 + (_riveAnimation.value * 0.2),
                                child: Opacity(
                                  opacity: _riveAnimation.value.clamp(0.0, 1.0),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Animated border ring
                                        AnimatedBuilder(
                                          animation: _backgroundController,
                                          builder: (context, child) {
                                            return Container(
                                              width: 420,
                                              height: 480,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: SweepGradient(
                                                  colors: [
                                                    const Color(0xFFD2A573).withValues(alpha: 0.0),
                                                    const Color(0xFFD2A573).withValues(alpha: 0.8),
                                                    const Color(0xFFD2A573).withValues(alpha: 0.0),
                                                  ],
                                                  stops: const [0.0, 0.5, 1.0],
                                                  transform: GradientRotation(_backgroundAnimation.value * 6.28),
                                                ),
                                              ),
                                              child: Container(
                                                margin: const EdgeInsets.all(3),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Outer glow effect
                                        Container(
                                          width: 400,
                                          height: 460,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                const Color(0xFFD2A573).withValues(alpha: 0.15),
                                                const Color(0xFFD2A573).withValues(alpha: 0.05),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Rive asset
                                        if (_teddyArtboard != null)
                                          Container(
                                            width: 380,
                                            height: 440,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.4),
                                                  blurRadius: 30,
                                                  offset: const Offset(0, 15),
                                                ),
                                                BoxShadow(
                                                  color: const Color(0xFFD2A573).withValues(alpha: 0.2),
                                                  blurRadius: 40,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: RadialGradient(
                                                    center: Alignment.center,
                                                    radius: 0.8,
                                                    colors: [
                                                      Colors.white.withValues(alpha: 0.1),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                                child: Rive(
                                                  artboard: _teddyArtboard!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Login Form
                          AnimatedBuilder(
                            animation: _formAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - _formAnimation.value)),
                                child: Opacity(
                                  opacity: _formAnimation.value,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 32),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: const Color(0xFFD2A573).withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(28),
                                      child: Column(
                                        children: [
                                          // Email field
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              color: Colors.white.withValues(alpha: 0.05),
                                              border: Border.all(
                                                color: const Color(0xFFD2A573).withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: TextField(
                                              controller: _emailController,
                                              onTap: handleFocus,
                                              onChanged: moveEyeTrack,
                                              keyboardType: TextInputType.emailAddress,
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                color: Colors.white.withValues(alpha: 0.9),
                                              ),
                                              cursorColor: const Color(0xFFD2A573),
                                              decoration: InputDecoration(
                                                hintText: "Email",
                                                hintStyle: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  color: Colors.white.withValues(alpha: 0.5),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 18,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.email_outlined,
                                                  color: const Color(0xFFD2A573).withValues(alpha: 0.7),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 16),

                                          // Password field
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              color: Colors.white.withValues(alpha: 0.05),
                                              border: Border.all(
                                                color: const Color(0xFFD2A573).withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: TextField(
                                              controller: _passwordController,
                                              onTap: handlePasswordFocus,
                                              keyboardType: TextInputType.visiblePassword,
                                              obscureText: true,
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                color: Colors.white.withValues(alpha: 0.9),
                                              ),
                                              cursorColor: const Color(0xFFD2A573),
                                              decoration: InputDecoration(
                                                hintText: "Password",
                                                hintStyle: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  color: Colors.white.withValues(alpha: 0.5),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 18,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.lock_outline,
                                                  color: const Color(0xFFD2A573).withValues(alpha: 0.7),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: Checkbox(
                                                      value: _isChecked,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _isChecked = value ?? false;
                                                        });
                                                      },
                                                      activeColor: const Color(0xFFD2A573),
                                                      checkColor: Colors.black,
                                                      side: BorderSide(
                                                        color: const Color(0xFFD2A573).withValues(alpha: 0.5),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Remember me",
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white.withValues(alpha: 0.7),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFD2A573),
                                                  Color(0xFFB8956A),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFD2A573).withValues(alpha: 0.3),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: login,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 32,
                                                  vertical: 16,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                              ),
                                              child: Text(
                                                "Login",
                                                style: GoogleFonts.inter(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}