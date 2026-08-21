import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../widgets/qrferry_design.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  static const _issueUrl =
      'https://github.com/itskdey/qr_ferry_flutter/issues/new';
  static const _repoUrl = 'github.com/itskdey/qr_ferry_flutter';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperGrid(
        child: SafeArea(
          child: Column(
            children: [
              const _DetailsHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 34, 20, 48),
                  children: [
                    const MotionReveal(child: TechLabel('Project details')),
                    const SizedBox(height: 14),
                    const MotionReveal(
                      delay: Duration(milliseconds: 40),
                      offsetY: 18,
                      child: Text(
                        'Built to move bytes\nthrough light.',
                        style: TextStyle(
                          color: QrFerryDesign.ink,
                          fontSize: 48,
                          height: 0.91,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -3.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const MotionReveal(
                      delay: Duration(milliseconds: 80),
                      child: Text(
                        'QRFerry is an offline file-transfer experiment for Flutter. '
                        'The sender turns a file into a repeating optical stream; '
                        'the receiver rebuilds it from camera-decoded QR frames.',
                        style: TextStyle(
                          color: Color(0xFF3B444C),
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const MotionReveal(
                      delay: Duration(milliseconds: 120),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Tag('Flutter'),
                          _Tag('Local only'),
                          _Tag('FQR1'),
                          _Tag('Open source'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 38),
                    const _SectionTitle(
                      number: '01',
                      title: 'Developer',
                      subtitle: 'The person building and maintaining QRFerry.',
                    ),
                    const SizedBox(height: 14),
                    const _DeveloperCard(),
                    const SizedBox(height: 38),
                    const _SectionTitle(
                      number: '02',
                      title: 'How it works',
                      subtitle:
                          'One file. Two devices. The camera is the link.',
                    ),
                    const SizedBox(height: 14),
                    const _TransferPipeline(),
                    const SizedBox(height: 38),
                    const _SectionTitle(
                      number: '03',
                      title: 'Under the hood',
                      subtitle:
                          'The current MVP keeps the protocol intentionally small.',
                    ),
                    const SizedBox(height: 14),
                    const _ProtocolGrid(),
                    const SizedBox(height: 38),
                    const _SectionTitle(
                      number: '04',
                      title: 'Privacy & security',
                      subtitle:
                          'What QRFerry does—and what it deliberately does not claim.',
                    ),
                    const SizedBox(height: 14),
                    const _PrivacyCard(),
                    const SizedBox(height: 38),
                    const _SectionTitle(
                      number: '05',
                      title: 'Current limits',
                      subtitle:
                          'Important constraints of the present protocol.',
                    ),
                    const SizedBox(height: 14),
                    const _LimitationsCard(),
                    const SizedBox(height: 38),
                    const _SectionTitle(
                      number: '06',
                      title: 'Report a problem',
                      subtitle:
                          'Good bug reports make the optical link better.',
                    ),
                    const SizedBox(height: 14),
                    _ReportCard(
                      onCopyIssueLink: () => _copyIssueLink(context),
                      onCopyTemplate: () => _copyReportTemplate(context),
                    ),
                    const SizedBox(height: 38),
                    const _SectionTitle(
                      number: '07',
                      title: 'Open source',
                      subtitle:
                          'Explore the implementation, protocol, and history.',
                    ),
                    const SizedBox(height: 14),
                    _OpenSourceCard(onCopyRepository: () => _copyRepo(context)),
                    const SizedBox(height: 36),
                    const _Footer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyIssueLink(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _issueUrl));
    if (!context.mounted) return;
    _showCopied(context, 'Issue link copied');
  }

  Future<void> _copyRepo(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: 'https://$_repoUrl'));
    if (!context.mounted) return;
    _showCopied(context, 'Repository link copied');
  }

  Future<void> _copyReportTemplate(BuildContext context) async {
    const template = '''QRFerry bug report

Device:
OS version:
File type:
File size:
Sender FPS: 5 / 8 / 12
Session ID:
Receiver progress when it failed:
Rejected frames:

What happened:

What I expected:

Steps to reproduce:
1.
2.
3.
''';

    await Clipboard.setData(const ClipboardData(text: template));
    if (!context.mounted) return;
    _showCopied(context, 'Report template copied');
  }

  void _showCopied(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: QrFerryDesign.ink,
          content: Row(
            children: [
              const Icon(
                Icons.check_rounded,
                color: QrFerryDesign.signal,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: QrFerryDesign.paper,
        border: Border(bottom: BorderSide(color: QrFerryDesign.line)),
      ),
      child: Row(
        children: [
          Pressable(
            onTap: Get.back<void>,
            pressedOffset: 1,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.arrow_back_rounded, size: 21),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'DETAILS',
            style: TextStyle(
              color: QrFerryDesign.muted,
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Hero(
            tag: 'QRFerry',
            transitionOnUserGestures: true,
            createRectTween: (begin, end) =>
                MaterialRectCenterArcTween(begin: begin, end: end),
            flightShuttleBuilder:
                (
                  flightContext,
                  animation,
                  flightDirection,
                  fromHeroContext,
                  toHeroContext,
                ) {
                  // Pull the "from" and "to" styles straight off the Hero children
                  final fromText = fromHeroContext.widget as Hero;
                  final toText = toHeroContext.widget as Hero;

                  // Simpler & safer: just hardcode the two known styles here
                  const beginStyle = TextStyle(
                    color: QrFerryDesign.ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  );
                  const endStyle = TextStyle(
                    color: QrFerryDesign.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  );

                  final isPush = flightDirection == HeroFlightDirection.push;

                  return Material(
                    type: MaterialType.transparency,
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        // Ease the curve so it doesn't feel linear/robotic
                        final t = Curves.easeInOutCubic.transform(
                          animation.value,
                        );
                        final style = TextStyle.lerp(
                          isPush ? beginStyle : endStyle,
                          isPush ? endStyle : beginStyle,
                          t,
                        );
                        return Text(
                          'QRFerry',
                          textScaler: TextScaler.noScaling,
                          style: style,
                        );
                      },
                    ),
                  );
                },
            child: const Material(
              type: MaterialType.transparency,
              child: Text(
                'QRFerry',
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: QrFerryDesign.ink,
                  fontSize: 17, // or 23 on the home screen
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7, // or -0.8 on the home screen
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final String number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return MotionReveal(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              number,
              style: const TextStyle(
                color: QrFerryDesign.muted,
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: QrFerryDesign.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.9,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: QrFerryDesign.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(color: QrFerryDesign.line),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: QrFerryDesign.muted,
          fontFamily: 'monospace',
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  @override
  Widget build(BuildContext context) {
    return HardShadowBox(
      color: QrFerryDesign.ink,
      shadowColor: const Color(0xFF44515C),
      shadowOffset: 7,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                color: QrFerryDesign.signal,
                alignment: Alignment.center,
                child: const Text(
                  '</>',
                  style: TextStyle(
                    color: QrFerryDesign.ink,
                    fontFamily: 'monospace',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mean Pheakdey',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '@itskdey · Developer',
                      style: TextStyle(
                        color: Color(0xFFA7B0B8),
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF34414C), height: 1),
          const SizedBox(height: 16),
          const Text(
            'QRFerry is built as a practical Flutter experiment around optical '
            'transport, local-first architecture, binary protocols, camera '
            'decoding, and interaction design.',
            style: TextStyle(
              color: Color(0xFFC2C8CD),
              fontSize: 12,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 15),
          const Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _DarkTag('Flutter'),
              _DarkTag('Dart'),
              _DarkTag('GetX'),
              _DarkTag('QR / Camera'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkTag extends StatelessWidget {
  const _DarkTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: QrFerryDesign.darkInset,
        border: Border.all(color: const Color(0xFF394651)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: QrFerryDesign.signal,
          fontFamily: 'monospace',
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.55,
        ),
      ),
    );
  }
}

class _TransferPipeline extends StatelessWidget {
  const _TransferPipeline();

  static const _steps =
      <({String number, String title, String detail, IconData icon})>[
        (
          number: '01',
          title: 'Select',
          detail: 'Pick a local file. Nothing is uploaded.',
          icon: Icons.insert_drive_file_outlined,
        ),
        (
          number: '02',
          title: 'Prepare',
          detail: 'CRC32, optional gzip, metadata, then numbered chunks.',
          icon: Icons.memory_rounded,
        ),
        (
          number: '03',
          title: 'Broadcast',
          detail:
              'Each chunk becomes a raw binary QR frame and loops on screen.',
          icon: Icons.qr_code_2_rounded,
        ),
        (
          number: '04',
          title: 'Scan',
          detail: 'The other device collects unique frames in any order.',
          icon: Icons.center_focus_strong_rounded,
        ),
        (
          number: '05',
          title: 'Verify',
          detail: 'Reassemble, validate CRC/size, decompress, preview, save.',
          icon: Icons.verified_outlined,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return MotionReveal(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCFBF8),
          border: Border.all(color: QrFerryDesign.ink),
        ),
        child: Column(
          children: [
            for (var index = 0; index < _steps.length; index++) ...[
              _PipelineRow(
                step: _steps[index],
                isLast: index == _steps.length - 1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PipelineRow extends StatelessWidget {
  const _PipelineRow({required this.step, required this.isLast});

  final ({String number, String title, String detail, IconData icon}) step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: QrFerryDesign.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Text(
              step.number,
              style: const TextStyle(
                color: QrFerryDesign.muted,
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            color: step.number == '03'
                ? QrFerryDesign.signal
                : QrFerryDesign.ink,
            child: Icon(
              step.icon,
              size: 19,
              color: step.number == '03' ? QrFerryDesign.ink : Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    color: QrFerryDesign.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.detail,
                  style: const TextStyle(
                    color: QrFerryDesign.muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolGrid extends StatelessWidget {
  const _ProtocolGrid();

  static const _items = <({String value, String label})>[
    (value: 'FQR1', label: 'Protocol magic'),
    (value: '512 B', label: 'Default payload'),
    (value: 'CRC32 ×3', label: 'Integrity stages'),
    (value: '5 / 8 / 12', label: 'Sender FPS'),
    (value: '20 MB', label: 'Current file cap'),
    (value: 'GZIP', label: 'Optional compression'),
  ];

  @override
  Widget build(BuildContext context) {
    return MotionReveal(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 9) / 2;
          return Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final item in _items)
                SizedBox(
                  width: width,
                  child: Container(
                    height: 92,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.66),
                      border: Border.all(color: QrFerryDesign.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.value,
                          style: const TextStyle(
                            color: QrFerryDesign.ink,
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label.toUpperCase(),
                          style: const TextStyle(
                            color: QrFerryDesign.muted,
                            fontFamily: 'monospace',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    return HardShadowBox(
      color: QrFerryDesign.ink,
      shadowColor: const Color(0xFF44515C),
      shadowOffset: 7,
      padding: const EdgeInsets.all(18),
      child: const Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FactLine(
            icon: Icons.cloud_off_outlined,
            text:
                'No backend, account, upload path, Wi-Fi, or Bluetooth is required.',
          ),
          _FactLine(
            icon: Icons.visibility_outlined,
            text:
                'The QR stream is visible and is not encrypted in the current MVP.',
          ),
          _FactLine(
            icon: Icons.shield_outlined,
            text:
                'CRC32 detects accidental corruption; it is not authentication.',
          ),
          _FactLine(
            icon: Icons.videocam_outlined,
            text:
                'Someone who records the complete optical stream may reconstruct the file.',
            last: true,
          ),
        ],
      ),
    );
  }
}

class _FactLine extends StatelessWidget {
  const _FactLine({required this.icon, required this.text, this.last = false});

  final IconData icon;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: QrFerryDesign.signal, size: 17),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFC2C8CD),
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitationsCard extends StatelessWidget {
  const _LimitationsCard();

  static const _items = [
    'Maximum input size is currently 20 MB.',
    'No encryption, password protection, or sender authentication yet.',
    'No fountain / RaptorQ forward-error correction in the current protocol.',
    'Missed chunks are recovered when the sender loops back to them.',
    'Receive sessions are not resumable after the app or screen is closed.',
  ];

  @override
  Widget build(BuildContext context) {
    return MotionReveal(
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFBF8),
          border: Border.all(color: QrFerryDesign.ink),
        ),
        child: Column(
          children: [
            for (var i = 0; i < _items.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == _items.length - 1 ? 0 : 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      color: QrFerryDesign.ink,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: QrFerryDesign.signal,
                          fontFamily: 'monospace',
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        _items[i],
                        style: const TextStyle(
                          color: QrFerryDesign.muted,
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.onCopyIssueLink,
    required this.onCopyTemplate,
  });

  final VoidCallback onCopyIssueLink;
  final VoidCallback onCopyTemplate;

  @override
  Widget build(BuildContext context) {
    return HardShadowBox(
      color: const Color(0xFFFCFBF8),
      shadowOffset: 7,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            color: QrFerryDesign.red,
            child: const Text(
              'BUG / FEEDBACK',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Found something weird?',
            style: TextStyle(
              color: QrFerryDesign.ink,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Include the device, OS, file type and size, sender FPS, session ID, '
            'receiver progress, and rejected-frame count when possible.',
            style: TextStyle(
              color: QrFerryDesign.muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _UtilityButton(
            icon: Icons.bug_report_outlined,
            label: 'Copy GitHub issue link',
            onTap: onCopyIssueLink,
          ),
          const SizedBox(height: 8),
          _UtilityButton(
            icon: Icons.content_copy_rounded,
            label: 'Copy report template',
            onTap: onCopyTemplate,
          ),
        ],
      ),
    );
  }
}

class _UtilityButton extends StatelessWidget {
  const _UtilityButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedOffset: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: QrFerryDesign.ink),
        ),
        child: Row(
          children: [
            Icon(icon, color: QrFerryDesign.ink, size: 18),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: QrFerryDesign.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 17),
          ],
        ),
      ),
    );
  }
}

class _OpenSourceCard extends StatelessWidget {
  const _OpenSourceCard({required this.onCopyRepository});

  final VoidCallback onCopyRepository;

  @override
  Widget build(BuildContext context) {
    return MotionReveal(
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.62),
          border: Border.all(color: QrFerryDesign.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MetaRow(label: 'Repository', value: DetailsScreen._repoUrl),
            const SizedBox(height: 10),
            const _MetaRow(label: 'License', value: 'MIT'),
            const SizedBox(height: 10),
            const _MetaRow(label: 'Protocol', value: 'FQR1 / v1'),
            const SizedBox(height: 10),
            const _MetaRow(
              label: 'Inspired by',
              value: 'deedy/qr-data-transfer',
            ),
            const SizedBox(height: 15),
            Pressable(
              onTap: onCopyRepository,
              pressedOffset: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                color: QrFerryDesign.ink,
                child: const Row(
                  children: [
                    Icon(
                      Icons.code_rounded,
                      color: QrFerryDesign.signal,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'COPY REPOSITORY LINK',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.65,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.content_copy_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: QrFerryDesign.muted,
              fontFamily: 'monospace',
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.45,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: QrFerryDesign.ink,
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Divider(color: QrFerryDesign.ink, height: 1),
        SizedBox(height: 18),
        Text(
          'QRFERRY  ·  FLUTTER  ·  FQR1  ·  LOCAL ONLY',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: QrFerryDesign.muted,
            fontFamily: 'monospace',
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Developed by Mean Pheakdey · @itskdey',
          textAlign: TextAlign.center,
          style: TextStyle(color: QrFerryDesign.muted, fontSize: 11),
        ),
      ],
    );
  }
}
