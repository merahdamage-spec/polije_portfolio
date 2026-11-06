import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  final String name, nim, prodi, email, bio, skills, prodiDesc;
  const Profile({
    required this.name,
    required this.nim,
    required this.prodi,
    required this.email,
    required this.bio,
    required this.skills,
    required this.prodiDesc,
  });

  /// Ganti nilai default ini dengan identitasmu.
  static const empty = Profile(
    name: 'Dia Putra A.I.S',
    nim: 'E41250875',
    prodi: 'D4 Teknik Informatika',
    email: 'e41250875@student.polije.ac.id',
    bio:
        'Mahasiswa POLIJE yang tertarik pada pengembangan aplikasi mobile dan web.',
    skills: 'Flutter, Dart, MySQL, Git',
    prodiDesc:
        'Program studi yang mempelajari pengembangan perangkat lunak dengan porsi praktik yang besar.',
  );
}

class ProfileStore {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();
  final ValueNotifier<Profile> profile = ValueNotifier(Profile.empty);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    const d = Profile.empty;
    profile.value = Profile(
      name: p.getString('name') ?? d.name,
      nim: p.getString('nim') ?? d.nim,
      prodi: p.getString('prodi') ?? d.prodi,
      email: p.getString('email') ?? d.email,
      bio: p.getString('bio') ?? d.bio,
      skills: p.getString('skills') ?? d.skills,
      prodiDesc: p.getString('prodiDesc') ?? d.prodiDesc,
    );
  }

  Future<void> save(Profile v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('name', v.name);
    await p.setString('nim', v.nim);
    await p.setString('prodi', v.prodi);
    await p.setString('email', v.email);
    await p.setString('bio', v.bio);
    await p.setString('skills', v.skills);
    await p.setString('prodiDesc', v.prodiDesc);
    profile.value = v;
  }
}
