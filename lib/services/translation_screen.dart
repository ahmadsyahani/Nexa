class AppTranslations {
  static Map<String, Map<String, String>> data = {
    'id': {
      // Home
      'hi_greeting': 'Halo',
      'quick_menu': 'Menu Kilat',
      'schedule_today': 'Jadwal Hari ini',
      'task_list': 'Daftar Tugas',
      'menu_absen': 'Absen',
      'menu_links': 'Links',
      'menu_notes': 'Catatan',
      'id_semester': 'Semester',
      'id_status': 'Status',
      'id_active': 'Aktif',
      'no_class': 'Tidak ada kelas hari ini',
      'task_all_done': 'Mantap! Semua tugas beres 🎉',
      'task_done': 'Selesai',
      'task_undone': 'Belum Selesai',
      'presensi_success_title': 'Presensi Berhasil!',
      'presensi_failed_title': 'Oops!',
      'presensi_no_data': 'Tidak ada presensi yang terdeteksi.',
      'presensi_net_error': 'Terjadi kesalahan jaringan.',
      'btn_close': 'Tutup',
      'btn_finish': 'Selesai',

      'menu_ipk': 'Kalkulator IPK',
      'ips_title': 'Indeks Semester (IPS)',
      'ipk_title': 'Indeks Kumulatif (IPK)',
      'add_course': 'Tambah Matkul',

      // Jadwal
      'day_senin': 'Senin', 'day_selasa': 'Selasa', 'day_rabu': 'Rabu',
      'day_kamis': 'Kamis',
      'day_jumat': "Jum'at",
      'day_sabtu': 'Sabtu',
      'day_minggu': 'Minggu',
      'jadwal_title': 'Jadwal Kuliah',
      'jadwal_error': 'Gagal memuat jadwal.',
      'no_room': 'Ruangan tidak ada',
      'default_matkul': 'Mata Kuliah',
      'default_dosen': 'Dosen',
      'jadwal_empty': 'Tidak ada jadwal kuliah.',

      // Navbar & Profile
      'profil_title': 'Profil',
      'settings_acc': 'Pengaturan Akun',
      'menu_detail': 'Detail Profil',
      'menu_lang': 'Bahasa',
      'menu_theme': 'Personalisasi',
      'section_other': 'Lainnya',
      'menu_help': 'Pusat Bantuan',
      'menu_about': 'Tentang Aplikasi',
      'btn_logout': 'Keluar Akun',
      'nav_home': 'Home',
      'nav_jadwal': 'Jadwal',
      'nav_tugas': 'Tugas',
      'nav_absen': 'Absen',

      // Tugas
      'tugas_header': 'Daftar Tugas',
      'tugas_error': 'Gagal memuat tugas.',
      'label_deadline': 'Tenggat',
      'empty_undone': 'Mantap! Tugas beres semua 🎉',
      'empty_done': 'Belum ada tugas selesai',

      // Absensi
      'absen_header': 'Riwayat Presensi',
      'absen_empty': 'Belum ada riwayat presensi\nuntuk mata kuliah ini.',
      'time_just_now': 'Baru saja',

      //Notifikasi
      'notif_title': 'Notifikasi',
      'filter_all': 'Semua',
      'filter_task': 'Tugas',
      'filter_presence': 'Presensi',
      'filter_announcement': 'Pengumuman',
      'notif_error': 'Gagal memuat notifikasi.',
      'notif_empty': 'Tidak ada notifikasi',

      // Personalisasi
      'theme_title': 'Personalisasi',
      'dark_mode': 'Mode Gelap',
      'dark_mode_desc': 'Gunakan tema gelap untuk aplikasi',

      // Detail Profil
      'detail_title': 'Detail Profil',
      'label_nama': 'Nama Lengkap',
      'label_nrp': 'NRP',
      'label_email': 'Email Mahasiswa', 'label_status': 'Status Mahasiswa',
      'no_email': 'Tidak ada email', 'status_active': 'Aktif',

      // Bantuan
      'help_title': 'Pusat Bantuan',
      'help_q1': 'Bagaimana cara mengubah password?',
      'help_a1':
          'Untuk saat ini, perubahan password hanya dapat dilakukan melalui portal web resmi Ethol PENS.',
      'help_q2': 'Kenapa jadwal saya kosong?',
      'help_a2':
          'Pastikan dosen mata kuliah Anda sudah mempublikasikan jadwal di sistem akademik.',
      'help_q3': 'Apakah aplikasi ini resmi dari PENS?',
      'help_a3':
          'Aplikasi ini adalah klien alternatif (3rd party) yang dibuat untuk memudahkan akses ke layanan Ethol.',

      'about_title': 'Tentang Aplikasi',
      'app_version': 'Versi',
      'dev_by': 'Dikembangkan oleh',
    },
    'en': {
      'hi_greeting': 'Hi',
      'quick_menu': 'Quick Menu',
      'schedule_today': "Today's Schedule",
      'task_list': 'Task List',
      'menu_absen': 'Presence',
      'menu_links': 'Links',
      'menu_notes': 'Notes',
      'id_semester': 'Semester',
      'id_status': 'Status',
      'id_active': 'Active',
      'no_class': 'No classes today',
      'task_all_done': 'Awesome! All tasks done 🎉',
      'task_done': 'Done',
      'task_undone': 'Undone',
      'presensi_success_title': 'Attendance Success!',
      'presensi_failed_title': 'Oops!',
      'presensi_no_data': 'No attendance detected.',
      'presensi_net_error': 'Network error occurred.',
      'btn_close': 'Close',
      'btn_finish': 'Done',

      'menu_ipk': 'GPA Calculator',
      'ips_title': 'Semester GPA (IPS)',
      'ipk_title': 'Cumulative GPA (IPK)',
      'add_course': 'Add Course',

      'day_senin': 'Monday',
      'day_selasa': 'Tuesday',
      'day_rabu': 'Wednesday',
      'day_kamis': 'Thursday',
      'day_jumat': 'Friday',
      'day_sabtu': 'Saturday',
      'day_minggu': 'Sunday',
      'jadwal_title': 'Course Schedule',
      'jadwal_error': 'Failed to load schedule.',
      'no_room': 'No room available',
      'default_matkul': 'Subject',
      'default_dosen': 'Lecturer',
      'jadwal_empty': 'No schedule available.',

      'tugas_header': 'Task List',
      'tugas_error': 'Failed to load tasks.',
      'label_deadline': 'Deadline',
      'empty_undone': 'Awesome! All tasks done 🎉',
      'empty_done': 'No completed tasks yet',

      'absen_header': 'Attendance History',
      'absen_empty': 'No attendance history found\nfor this course.',
      'time_just_now': 'Just now',

      'profil_title': 'Profile',
      'settings_acc': 'Account Settings',
      'menu_detail': 'Profile Detail',
      'menu_lang': 'Language',
      'menu_theme': 'Personalization',
      'section_other': 'Others',
      'menu_help': 'Help Center',
      'menu_about': 'About App',
      'btn_logout': 'Logout',
      'nav_home': 'Home',
      'nav_jadwal': 'Schedule',
      'nav_tugas': 'Tasks',
      'nav_absen': 'Attendance',

      'notif_title': 'Notifications',
      'filter_all': 'All',
      'filter_task': 'Tasks',
      'filter_presence': 'Attendance',
      'filter_announcement': 'Announcements',
      'notif_error': 'Failed to load notifications.',
      'notif_empty': 'No notifications found for',

      'theme_title': 'Personalization',
      'dark_mode': 'Dark Mode',
      'dark_mode_desc': 'Use dark theme for the app',

      'detail_title': 'Profile Detail',
      'label_nama': 'Full Name',
      'label_nrp': 'NRP',
      'label_email': 'Student Email',
      'label_status': 'Student Status',
      'no_email': 'No email available',
      'status_active': 'Active',

      'help_title': 'Help Center',
      'help_q1': 'How to change my password?',
      'help_a1':
          'For now, password changes can only be made through the official Ethol PENS web portal.',
      'help_q2': 'Why is my schedule empty?',
      'help_a2':
          'Make sure your course lecturer has published the schedule in the academic system.',
      'help_q3': 'Is this app official from PENS?',
      'help_a3':
          'This app is an alternative (3rd party) client created to simplify access to Ethol services.',

      'about_title': 'About Application',
      'app_version': 'Version',
      'dev_by': 'Developed by',
    },
  };

  static String getText(String key, String langCode) {
    return data[langCode]?[key] ?? key;
  }
}
