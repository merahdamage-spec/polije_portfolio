<?php
require __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') respond(false, null, 'Method tidak didukung', 405);

$action = $_GET['action'] ?? '';
$in     = jsonInput();
$pdo    = db();

function issueToken(PDO $pdo, int $id): string {
    $token = bin2hex(random_bytes(32));
    $pdo->prepare('UPDATE users SET api_token = ? WHERE id = ?')->execute([$token, $id]);
    return $token;
}

try {
    switch ($action) {

        case 'register':
            $name     = trim($in['name'] ?? '');
            $username = strtolower(trim($in['username'] ?? ''));
            $pass     = (string)($in['password'] ?? '');
            if (mb_strlen($name) < 3)                          respond(false, null, 'Nama minimal 3 karakter', 422);
            if (!preg_match('/^[a-z0-9_.]{3,30}$/', $username)) respond(false, null, 'Username 3-30 karakter: huruf, angka, titik, atau garis bawah', 422);
            if (strlen($pass) < 6)                             respond(false, null, 'Password minimal 6 karakter', 422);

            $st = $pdo->prepare('SELECT id FROM users WHERE username = ?');
            $st->execute([$username]);
            if ($st->fetch()) respond(false, null, 'Username sudah dipakai', 409);

            $st = $pdo->prepare('INSERT INTO users (name, username, password_hash) VALUES (?, ?, ?)');
            $st->execute([$name, $username, password_hash($pass, PASSWORD_DEFAULT)]);
            $token = issueToken($pdo, (int)$pdo->lastInsertId());
            respond(true, ['token' => $token, 'name' => $name, 'username' => $username], 'Registrasi berhasil', 201);

        case 'login':
            $username = strtolower(trim($in['username'] ?? ''));
            $pass     = (string)($in['password'] ?? '');
            if ($username === '' || $pass === '') respond(false, null, 'Username dan password wajib diisi', 422);

            $st = $pdo->prepare('SELECT id, name, username, password_hash FROM users WHERE username = ?');
            $st->execute([$username]);
            $u = $st->fetch();
            if (!$u || !password_verify($pass, $u['password_hash'])) {
                respond(false, null, 'Username atau password salah', 401);
            }
            $token = issueToken($pdo, (int)$u['id']);
            respond(true, ['token' => $token, 'name' => $u['name'], 'username' => $u['username']], 'Login berhasil');

        case 'logout':
            $token = (string)($in['token'] ?? '');
            if ($token !== '') $pdo->prepare('UPDATE users SET api_token = NULL WHERE api_token = ?')->execute([$token]);
            respond(true, null, 'Logout berhasil');

        default:
            respond(false, null, 'Aksi tidak dikenal', 400);
    }
} catch (PDOException $e) {
    respond(false, null, 'Kesalahan database: ' . $e->getMessage(), 500);
}