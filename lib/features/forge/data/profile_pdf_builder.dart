import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../../profile/domain/models/profile_model.dart';

enum PdfTheme { modern, classic }

class ProfilePdfBuilder {
  static Future<pw.Document> build(UserProfile profile, PdfTheme theme) async {
    switch (theme) {
      case PdfTheme.modern:
        return _buildModern(profile);
      case PdfTheme.classic:
        return _buildClassic(profile);
    }
  }

  static pw.Document _buildModern(UserProfile profile) {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              profile.fullName.isEmpty ? 'Your name' : profile.fullName,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            if (profile.headline.isNotEmpty) pw.SizedBox(height: 4),
            if (profile.headline.isNotEmpty)
              pw.Text(
                profile.headline,
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            pw.SizedBox(height: 16),
            if (profile.bio.isNotEmpty)
              pw.Text(profile.bio, style: const pw.TextStyle(fontSize: 10)),
            if (profile.bio.isNotEmpty) pw.SizedBox(height: 16),
            if (profile.email.isNotEmpty)
              pw.Text(
                'Contact: ${profile.email}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            if (profile.skills.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text(
                'Skills',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Wrap(
                children: profile.skills
                    .map(
                      (s) => pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 8, bottom: 4),
                        child: pw.Text(
                          s.name,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (profile.experience.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text(
                'Experience',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              ...profile.experience.map(
                (e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${e.role}${e.company.isNotEmpty ? ' at ${e.company}' : ''}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (e.period.isNotEmpty)
                        pw.Text(
                          e.period,
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                      if (e.description.isNotEmpty)
                        pw.Text(
                          e.description,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (profile.links.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text(
                'Links',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              ...profile.links.map(
                (l) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(
                    '${l.title.isEmpty ? l.url : l.title}: ${l.url}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ),
            ],
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                '— ProfileForge',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return pdf;
  }

  static pw.Document _buildClassic(UserProfile profile) {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 12),
            pw.Text(
              profile.fullName.isEmpty ? 'Your name' : profile.fullName,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            if (profile.headline.isNotEmpty)
              pw.Text(
                profile.headline,
                style: const pw.TextStyle(fontSize: 11),
              ),
            pw.SizedBox(height: 12),
            pw.Divider(),
            if (profile.bio.isNotEmpty)
              pw.Paragraph(
                text: profile.bio,
                style: const pw.TextStyle(fontSize: 10),
              ),
            if (profile.email.isNotEmpty)
              pw.Text(profile.email, style: const pw.TextStyle(fontSize: 10)),
            if (profile.skills.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(
                'SKILLS',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                profile.skills.map((s) => s.name).join(' • '),
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
            if (profile.experience.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(
                'EXPERIENCE',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              ...profile.experience.map(
                (e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        e.role,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (e.company.isNotEmpty)
                        pw.Text(
                          e.company,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      if (e.period.isNotEmpty)
                        pw.Text(
                          e.period,
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey700,
                          ),
                        ),
                      if (e.description.isNotEmpty)
                        pw.Text(
                          e.description,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (profile.links.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(
                'LINKS',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              ...profile.links.map(
                (l) => pw.Text(
                  '${l.title.isEmpty ? '' : '${l.title}: '}${l.url}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
            pw.Spacer(),
            pw.Center(
              child: pw.Text(
                'ProfileForge',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return pdf;
  }

  /// Save to temp file and return path for sharing.
  static Future<String> saveToTempFile(pw.Document pdf) async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/profileforge_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }
}
