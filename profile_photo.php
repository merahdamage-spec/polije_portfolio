<?php
require __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'];
$pdo    = db();

try {
    switch ($method) {

        // ---------- READ ----------
        case 'GET':
            $st = $pdo->query('SELECT image, updated_at AS updatedAt FROM profile_photo WHERE id = 1');
            $row = $st->fetch();
            respond(true, $row ?: null);   // null jika belum ada foto

        // ---------- CREATE / UPDATE (upsert) ----------
        case 'POST':
        case 'PUT':
            $img = jsonInput()['image'] ?? '';
            if (!is_string($img) || $img === '') respond(false, null, 'Foto wajib diisi', 422);
            if (strlen($img) > 4000000)           respond(false, null, 'Ukuran foto terlalu besar', 422);
            $bin = base64_decode($img, true);
            if ($bin === false || @getimagesizefromstring($bin) === false) {
                respond(false, null, 'File bukan gambar yang valid', 422);
            }
            $st = $pdo->prepare('INSERT INTO profile_photo (id, image) VALUES (1, ?)
                                 ON DUPLICATE KEY UPDATE image = VALUES(image)');
            $st->execute([$img]);
            respond(true, null, 'Foto profil disimpan');

        // ---------- DELETE ----------
        case 'DELETE':
            $pdo->exec('DELETE FROM profile_photo WHERE id = 1');
            respond(true, null, 'Foto profil dihapus');

        default:
            respond(false, null, 'Method tidak didukung', 405);
    }
} catch (PDOException $e) {
    respond(false, null, 'Kesalahan database: ' . $e->getMessage(), 500);
}
