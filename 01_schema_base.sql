-- BLOCO 1: Estrutura base (usuários, medicamentos, horários e doses)
-- Comandos usados: CREATE DATABASE, USE, CREATE TABLE, PRIMARY KEY, FOREIGN KEY,
-- NOT NULL, UNIQUE, DEFAULT, CHECK, ALTER TABLE ADD CONSTRAINT
CREATE DATABASE IF NOT EXISTS app_medicamentos;
USE app_medicamentos;

CREATE TABLE usuario (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  senha_hash VARCHAR(255) NOT NULL,              -- nunca guardar senha pura
  data_nascimento DATE,
  status VARCHAR(15) NOT NULL DEFAULT 'ativo'
    CHECK (status IN ('ativo','inativo','anonimizado')),
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  anonimizado_em DATETIME
);

CREATE TABLE medicamento (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  nome VARCHAR(120) NOT NULL,
  forma VARCHAR(20) DEFAULT 'comprimido',        -- comprimido, capsula, gotas...
  dose VARCHAR(60) NOT NULL,                     -- ex.: '50 mg'
  quantidade_por_dose DECIMAL(5,2) DEFAULT 1 CHECK (quantidade_por_dose > 0),
  observacao VARCHAR(255),                       -- ex.: 'após o café'
  data_inicio DATE NOT NULL,
  data_fim DATE,                                 -- NULL = uso contínuo
  estoque_atual DECIMAL(7,2) DEFAULT 0 CHECK (estoque_atual >= 0),
  estoque_minimo DECIMAL(7,2) DEFAULT 0,
  ativo BOOLEAN DEFAULT TRUE,
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuario(id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE horario_medicamento (
  id INT PRIMARY KEY AUTO_INCREMENT,
  medicamento_id INT NOT NULL,
  horario TIME NOT NULL,                         -- ex.: '08:00:00'
  dias_semana VARCHAR(30) DEFAULT 'todos',       -- ex.: 'seg,qua,sex'
  ativo BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (medicamento_id) REFERENCES medicamento(id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE registro_dose (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  horario_id INT NOT NULL,
  data_prevista DATETIME NOT NULL,
  data_registro DATETIME,                        -- quando o usuário respondeu
  status VARCHAR(15) NOT NULL DEFAULT 'pendente'
    CHECK (status IN ('pendente','tomada','adiada','pulada','perdida')),
  observacao VARCHAR(255),
  FOREIGN KEY (horario_id) REFERENCES horario_medicamento(id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- Evita registrar a mesma dose duas vezes
ALTER TABLE registro_dose
  ADD CONSTRAINT uq_dose UNIQUE (horario_id, data_prevista);
