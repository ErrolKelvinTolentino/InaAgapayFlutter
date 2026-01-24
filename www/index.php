<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once "db.php";

$route = $_GET['route'] ?? '';

if ($route === 'read') {
    $result = $conn->query("SELECT * FROM users");
    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode($data);
    exit;
}

if ($route === 'create') {
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    if ($name == '' || $email == '') {
        echo json_encode(["error" => "Missing fields"]);
        exit;
    }
    $stmt = $conn->prepare("INSERT INTO users (name,email) VALUES (?,?)");
    $stmt->bind_param("ss", $name, $email);
    $stmt->execute();
    echo json_encode(["success" => true]);
    exit;
}

if ($route === 'delete') {
    $id = $_POST['id'] ?? '';
    if ($id == '') {
        echo json_encode(["error" => "Missing id"]);
        exit;
    }
    $stmt = $conn->prepare("DELETE FROM users WHERE id=?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    echo json_encode(["success" => true]);
    exit;
}

echo json_encode(["status" => "ok"]);
exit;
