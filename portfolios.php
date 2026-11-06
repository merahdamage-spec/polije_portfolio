<?php
require __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'];
$id     = isset($_GET['id']) ? (int) $_GET['id'] : 0;
$pdo    = db();

const COLS = 'id, title, category, technology, description,
              image_path AS imagePath, created_at AS createdAt';

/** Validasi sisi server (selain validasi di Flutter). */
function validate(array $in): array {
    $title = trim($in['title'] ?? '');
    $desc  = trim($in['description'] ?? '');
    $cat   = trim($in['category'] ?? '');
    $tech  = trim($in['technology'] ?? '');
    if (mb_strlen($title) < 3)  respond(false, null, 'Judul minimal 3 karakter', 422);
    if (mb_strlen($desc) < 10)  respond(false, null, 'Deskripsi minimal 10 karakter', 422);
    if ($cat === '' || $tech === '') respond(false, null, 'Kategori dan teknologi wajib diisi', 422);
    $img = $in['imagePath'] ?? null;
    return [$title, $cat, $tech, $desc, ($img === '' ? null : $img)];
}

try {
    switch ($method) {

        // ---------- READ ----------
        case 'GET':
            if ($id > 0) {
                $st = $pdo->prepare('SELECT ' . COLS . ' FROM portfolios WHERE id = ?');
                $st->execute([$id]);
                $row = $st->fetch();
                if (!$row) respond(false, null, 'Data tidak ditemukan', 404);
                respond(true, $row);
            }
            $where = []; $args = [];
            $category = trim($_GET['category'] ?? '');
            $keyword  = trim($_GET['keyword'] ?? '');
            if ($category !== '' && $category !== 'Semua') {
                $where[] = 'category = ?'; $args[] = $category;
            }
            if ($keyword !== '') {
                $where[] = '(title LIKE ? OR description LIKE ?)';
                $args[] = "%$keyword%"; $args[] = "%$keyword%";
            }
            $sql = 'SELECT ' . COLS . ' FROM portfolios'
                 . ($where ? ' WHERE ' . implode(' AND ', $where) : '')
                 . ' ORDER BY id DESC';
            $st = $pdo->prepare($sql);
            $st->execute($args);
            respond(true, $st->fetchAll());

        // ---------- CREATE ----------
        case 'POST':
            [$title, $cat, $tech, $desc, $img] = validate(jsonInput());
            $st = $pdo->prepare('INSERT INTO portfolios (title, category, technology, description, image_path)
                                 VALUES (?, ?, ?, ?, ?)');
            $st->execute([$title, $cat, $tech, $desc, $img]);
            respond(true, (int) $pdo->lastInsertId(), 'Data berhasil ditambahkan', 201);

        // ---------- UPDATE ----------
        case 'PUT':
            if ($id <= 0) respond(false, null, 'Parameter id wajib', 400);
            [$title, $cat, $tech, $desc, $img] = validate(jsonInput());
            $st = $pdo->prepare('UPDATE portfolios
                                 SET title=?, category=?, technology=?, description=?, image_path=?
                                 WHERE id=?');
            $st->execute([$title, $cat, $tech, $desc, $img, $id]);
            respond(true, $id, 'Data berhasil diperbarui');

        // ---------- DELETE ----------
        case 'DELETE':
            if (isset($_GET['all'])) {
                $pdo->exec('DELETE FROM portfolios');
                respond(true, null, 'Semua data dihapus');
            }
            if ($id <= 0) respond(false, null, 'Parameter id wajib', 400);
            $st = $pdo->prepare('DELETE FROM portfolios WHERE id = ?');
            $st->execute([$id]);
            if ($st->rowCount() === 0) respond(false, null, 'Data tidak ditemukan', 404);
            respond(true, null, 'Data berhasil dihapus');

        default:
            respond(false, null, 'Method tidak didukung', 405);
    }
} catch (PDOException $e) {
    respond(false, null, 'Kesalahan database: ' . $e->getMessage(), 500);
}
