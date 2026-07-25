<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

echo json_encode(
    [
        'status' => 'ok',
        'application' => 'teste-tecnico-analista-devops',
    ],
    JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES
);
