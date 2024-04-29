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

	
	
--1)
select j.nome, j.salario, s.nome as selecao
from jogador j
left join selecao s on j.codigo_selecao = s.codigo
where s.genero = 'feminino'
order by s.nome, j.nome;

--2) 

select e.nome as estadio, e.capacidade_maxima, p.nome as partida, p.fase
from estadio e
join partida p on e.codigo = p.codigo_estadio
where e.capacidade_maxima between 10000 and 70000
  and p.fase = 'grupo';


--3)


select p.nome as partida, s1.nome as selecao_a, s2.nome as selecao_b
from partida p
join selecao s1 on p.codigo_selecao_a = s1.codigo
join selecao s2 on p.codigo_selecao_b = s2.codigo;


--4)

select j.nome, coalesce(s.nome, 'sem seleção') as selecao
from jogador j
left join selecao s on j.codigo_selecao = s.codigo;


--5)


select j.nome, coalesce(s.nome, 'sem seleção') as selecao
from jogador j
left join selecao s on j.codigo_selecao = s.codigo
union
select 'sem jogadora', s.nome
from selecao s
where not exists (select 1 from jogador j where j.codigo_selecao = s.codigo);


--6) Selecione o nome e a renda dos torcedores, nome da seleção do torcedor, os estádios que ele
--visitou e a data da visita. Ordene a saída pelo nome do estádio. Limite a saída para 3 a partir do
--segundo.


select t.nome, t.renda, s.nome, e.nome, et.data
from torcedor t 
join selecao s on t.codigo_selecao = s.codigo
join estadio_torcedor et on t.codigo = et.codigo_torcedor
join estadio e on et.codigo_estadio = e.codigo 
order by e.nome
offset 1 limit 3;


--7) Selecione o nome do estádio, da partida e das seleções que jogaram as partidas. Considere
--somente as partidas da fase oitavas, com valor de ingresso maior que R$ 100,00, que aconteceram
--em 2023 nos estádios construídos em 2022.

select e.nome, p.nome, s1.nome, s2.nome
from estadio e 
join partida p on e.codigo = p.codigo_estadio 
join selecao s1 on p.codigo_selecao_a = s1.codigo
join selecao s2 on p.codigo_selecao_b = s2.codigo
where p.fase = 'oitavas' and p.valor_ingresso > 100.00 
and p.data between '2023-01-01 00:00:00' and '2023-12-31 23:59:59'
and e.data_fundacao between '2022-01-01' and '2022-12-31';




