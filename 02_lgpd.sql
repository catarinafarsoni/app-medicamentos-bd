-- BLOCO 2: LGPD (termos, consentimentos, direitos do titular e anonimização)
-- Dados de saúde são dados sensíveis (LGPD, art. 11): exigem consentimento específico.
USE app_medicamentos;

CREATE TABLE termo_versao (
	id INT PRIMARY KEY AUTO_INCREMENT,
	tipo VARCHAR(25) NOT NULL
		CHECK (tipo IN ('termos_uso','politica_privacidade')),
	versao VARCHAR(20) NOT NULL,
	texto TEXT NOT NULL,
	vigente_desde DATE NOT NULL,
	CONSTRAINT uq_termo UNIQUE (tipo, versao)
);

CREATE TABLE consentimento (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	usuario_id INT NOT NULL,
	termo_versao_id INT NOT NULL,
	finalidade VARCHAR(30) NOT NULL
		CHECK (finalidade IN
('tratamento_dados_saude','notificacoes','compartilhamento_cuidador')),
	concedido_em DATETIME DEFAULT CURRENT_TIMESTAMP,
	revogado_em DATETIME,                  -- revogar = preencher esta data (mantém histórico)  
	ip_origem VARCHAR(45),
	FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
	FOREIGN KEY (termo_versao_id) REFERENCES termo_versao(id)
);

CREATE TABLE solicitacao_titular ( 
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	usuario_id INT NOT NULL,
	tipo VARCHAR(30) NOT NULL
		CHECK (tipo IN
 ('acesso','correcao','portabilidade','exclusao','revogacao_consentimento')),
   status VARCHAR(15) NOT NULL DEFAULT 'aberta'
		CHECK (status IN ('aberta','em_andamento','concluida','negada')),
	descricao VARCHAR(255),
	aberta_em DATETIME DEFAULT CURRENT_TIMESTAMP,
	concluida_em DATETIME,
	FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- ROTINA DE ANONIMIZAÇÃO (pedido de exclusão de conta)
-- Executar trocando o 1 pelo id do usuário. Apaga os dados de saúde e os
-- identificadores pessoais, mas mantém o registro da conta e a auditoria.
-- DELETE FROM medicamento WHERE usuario_id = 1;
-- UPDATE consentimento SET revogado_em = NOW() WHERE usuario_id = 1 AND revogado_em IS NULL;
-- UPDATE usuario--    SET nome = 'Usuário anonimizado',
--        email = CONCAT('anonimo_', id, '@anonimo.invalid'),
--        senha_hash = '',
--        data_nascimento = NULL,
--        status = 'anonimizado',
--        anonimizado_em = NOW()
--  WHERE id = 1;
-- UPDATE solicitacao_titular SET status = 'concluida', concluida_em = NOW()
--  WHERE usuario_id = 1 AND tipo = 'exclusao' AND status <> 'concluida'; ESSE CODIGO ESTA CERTO
