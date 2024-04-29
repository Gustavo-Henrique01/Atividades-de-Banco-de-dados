-- Criação da tabela selecao
create table selecao (
    codigo serial not null,
    nome varchar(100),
    pais varchar(50),
    genero varchar(10),
	primary key (codigo)
);
insert into selecao (nome, pais, genero) 
values ('brasil', 'brasil', 'masculino'); 
insert into selecao (nome, pais, genero)
 values ('estados unidos', 'eua', 'feminino');
insert into selecao (nome, pais, genero)
values ('frança', 'frança', 'masculino');

-- Criação da tabela jogador
create table jogador (
    codigo serial not null ,
    nome varchar(100),
    data_nascimento date,
    salario numeric(20,2),
    time varchar(100),
    posicao varchar(50),
    codigo_selecao integer,
	primary key (codigo),
    foreign key (codigo_selecao) references selecao(codigo)
);

-- Inserção de registros na tabela jogador
-- Inserir dados na tabela jogador
insert into jogador (nome, data_nascimento, salario, time, posicao, codigo_selecao) 
values('neymar', '1992-02-05', 1000000, 'paris saint-germain', 'atacante', 1);

insert into jogador (nome, data_nascimento, salario, time, posicao, codigo_selecao) 
values ('megan rapinoe', '1985-07-05', 500000, 'ol reign', 'meia', 2);

insert into jogador (nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('kylian mbappé', '1998-12-20', 800000, 'paris saint-germain', 'atacante', 3);

CREATE TYPE fase AS ENUM ('grupo', 'oitavas', 'quartas', 'semi','final');

-- Criação da tabela partida
create table partida (
    codigo serial not null,
    nome varchar(100),
    data timestamp,
    fase  fase ,
    valor_ingresso numeric,
    quantidade_ingresso integer,
    codigo_estadio integer,
    codigo_selecao_a integer,
    codigo_selecao_b integer,
    primary key (codigo),
    foreign key (codigo_estadio) references estadio(codigo),
    foreign key (codigo_selecao_a) references selecao(codigo),
    foreign key (codigo_selecao_b) references selecao(codigo)
);


-- Inserção de registros na tabela partida
-- Inserir dados na tabela partida
insert into partida (nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values ('brasil x argentina', '2023-07-15 20:00:00', 'final', 100, 50000, 1, 1, 2);

insert into partida (nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b) 
values  ('eua x frança', '2023-07-10 18:30:00', 'quartas', 75, 35000, 2, 2, 3);

insert into partida (nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b) 
values    ('brasil x frança', '2023-06-28 15:00:00', 'oitavas', 60, 30000, 1, 1, 3);


-- Criação da tabela estadio
create table estadio (
    codigo serial not null ,
    nome varchar(100),
    capacidade_maxima integer,
    custo_construcao numeric,
    data_fundacao date,
	primary key (codigo)
);

-- Inserção de registros na tabela estadio
-- Inserir dados na tabela estadio
insert into estadio (nome, capacidade_maxima, custo_construcao, data_fundacao)
values  ('maracanã', 78000, 150000000, '1950-06-16');

insert into estadio (nome, capacidade_maxima, custo_construcao, data_fundacao)
values    ('red bull arena', 25000, 70000000, '2010-03-20');

insert into estadio (nome, capacidade_maxima, custo_construcao, data_fundacao)
values   ('stade de france', 81000, 180000000, '1998-01-28');

 CREATE TYPE sexo as enum ('feminino', 'masculino', 'outros')
-- Criação da tabela torcedor
create table torcedor (
    codigo serial not null ,
    nome varchar(100),
    data_nascimento date,
    renda numeric,
    genero sexo ,
    codigo_selecao integer ,
	primary key (codigo),
	foreign key (codigo_selecao)references selecao(codigo)
);

-- Inserção de registros na tabela torcedor
-- Inserir dados na tabela torcedor
insert into torcedor (nome, data_nascimento, renda, genero, codigo_selecao)
values   ('ana silva', '1988-09-12', 5000, 'feminino', 1);

insert into torcedor (nome, data_nascimento, renda, genero, codigo_selecao) 
values    ('joão pereira', '1995-05-20', 6000, 'masculino', 2);

insert into torcedor (nome, data_nascimento, renda, genero, codigo_selecao) 
values   ('alexis martin', '1980-11-03', 7500, 'outros', 3);

-- Criação da tabela estadio_torcedor
create table estadio_torcedor (
    codigo_estadio integer ,
    codigo_torcedor integer,
    data timestamp,
	primary key ( codigo_estadio, codigo_torcedor) 
	
);

-- Inserção de registros na tabela estadio_torcedor
-- Inserir dados na tabela estadio_torcedor
insert into estadio_torcedor (codigo_estadio, codigo_torcedor, data)
values   (1, 1, '2023-07-15 19:30:00');

insert into estadio_torcedor (codigo_estadio, codigo_torcedor, data)
values    (2, 2, '2023-07-10 17:45:00');

insert into estadio_torcedor (codigo_estadio, codigo_torcedor, data) 
values (3, 3, '2023-06-28 14:15:00');

	
	

