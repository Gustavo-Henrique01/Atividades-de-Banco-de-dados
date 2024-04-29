--ordenar as tabelas


create type genero_enum as enum ('feminino', 'masculino', 'outros');
create table selecao(
	codigo serial not null, 
	nome varchar(50) not null, 
	pais varchar(50), 
	genero genero_enum,
	primary key(codigo)
);

insert into selecao(nome, pais, genero)
values('Brasileira', 'Brasil', 'feminino');
insert into selecao(nome, pais, genero)
values('Japonesa', 'Japão', 'feminino');
insert into selecao(nome, pais, genero)
values('Jamaicana', 'Jamaica', 'feminino');

select * from selecao;   
create table estadio(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	capacidade_maxima int, 
	custo_construcao numeric(20,2), 
	data_fundacao date
);

insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Maracanã', 78000, 5000000000, '1950-06-16');
insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Morenão', 45000, 1000000000, '1971-03-07');
insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Elias Gadia', 2500, 5000000, '1990-12-25');

create table jogador(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	data_nascimento date, 
	salario numeric(20,2), 
	time varchar(50), 
	posicao varchar(50), 
	codigo_selecao int,
	foreign key(codigo_selecao) references selecao(codigo)
);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Marta','1986-02-19', 2000000, 'Orlando', 'Atacante', 1);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Formiga','1978-03-03', 1000000, 'Santos', 'volante', 1);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Khalix','1992-08-26', 500000, 'Vasco', 'Goleira', 3);

create type fase_enum as enum ('grupo','oitavas', 'quartas', 'semi', 'final');

create table partida(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	data timestamp, 
	fase fase_enum, 
	valor_ingresso numeric(8,2), 
	quantidade_ingresso int, 
	codigo_estadio int references estadio(codigo),     
	codigo_selecao_a int references selecao(codigo), 
	codigo_selecao_b int references selecao(codigo)
);

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Final da Copa', '2023-08-20 06:00:00', 'final', 15000, 78000, 1, 1, 3);

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Disputa Terceiro Lugar', '2023-08-19 06:00:00', 'final', 5000, 2500, 3, 2, 3);

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Grupo A', '2023-07-24 06:00:00', 'grupo', 1000, 78000, 1, 1, 2);

create table torcedor(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	data_nascimento date, 
	renda numeric(20,2), 
	genero genero_enum, 
	codigo_selecao int references selecao(codigo)
);

insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Fulano', '1959-08-26', 2587416, 'masculino', 1);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Fulana', '1959-09-07', 2587416, 'feminino', 1);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Fulaninho', '1984-04-01', 2587416, 'masculino', 1);

create table estadio_torcedor(
	codigo_estadio int references estadio (codigo), 
	codigo_torcedor int references torcedor(codigo), 
	data timestamp,
	primary key(codigo_estadio, codigo_torcedor)
);

insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(1, 2, current_timestamp);
insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(3, 1, current_timestamp);
insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(2, 2, current_timestamp);


--1) Selecione o nome das jogadoras, data de nascimento, idade em anos e o nome da seleção que
--cada uma joga. Considere que todas as datas devem sair no formato DD/MM/YYYY. Ordene a saída
--pela data de nascimento.
SELECT 
    j.nome AS "Nome da Jogadora",
    TO_CHAR(j.data_nascimento, 'DD/MM/YYYY') AS "Data de Nascimento",
    DATE_PART('year', AGE(current_date, j.data_nascimento)) AS "Idade",
    s.nome AS "Seleção que Joga"
FROM jogador j
JOIN selecao s ON j.codigo_selecao = s.codigo
WHERE s.genero = 'feminino'
ORDER BY j.data_nascimento;

--2) Selecione o nome da(s) partidas(s) mais caras

SELECT nome, valor_ingresso
FROM partida
WHERE valor_ingresso = (SELECT MAX(valor_ingresso) FROM partida);


--3) Selecione o nome da partida e das seleções que disputaram a(s) partida(s) com o ingresso mais
--barato.

select p.nome , s.nome ,s2.nome
from partida p 
join selecao s on  s.codigo = p.codigo_selecao_a
join selecao s2 on s2.codigo = p.codigo_selecao_b
where p.valor_ingresso = (select min (valor_ingresso) from partida);

--4) Qual a data de fundação dos estádios fundados a 100 dias. Formate a saída para o padrão
--DD/MM/YYYY

SELECT TO_CHAR(data_fundacao - INTERVAL '100 days', 'DD/MM/YYYY') AS "Data de Fundação"
FROM estadio
WHERE data_fundacao >= (CURRENT_DATE - INTERVAL '100 days');

--5) Qual a data de fundação dos estádios fundados a 5 anos. Formate a saída para o padrão DD/MM/
--YYYY
select to_char(e.data_fundacao - interval '5 years', 'DD/MM/YYYY') as "Data de fundação 5 anos"
from estadio e
where data_fundacao >= (current_date - interval '5 years');

--6) Selecione o nome e o tempo de fundação em anos dos estádios que possuam partidas
--disputadas em 2023

SELECT e.nome AS "Nome do Estádio", 
       EXTRACT(YEAR FROM AGE(current_date, e.data_fundacao)) AS "Tempo de Fundação (Anos)"
FROM estadio e
WHERE EXISTS (
    SELECT 
    FROM partida p
    WHERE p.codigo_estadio = e.codigo
    AND EXTRACT(YEAR FROM p.data) = 2023
	
);


--7) Selecione o nome e a data da partida no padrão nacional ( Ex: 31/08/2023 19:50:11). Somente
---partidas em que o nome termine com a letra ‘a’, possuam tamanho mínimo de 7 letras no nome e
--que tem valor do ingresso abaixo da média devem ser mostradas. Atenção, não é permitido
--saídas duplicadas.

SELECT p.nome, TO_CHAR(p.data, 'DD/MM/YYYY HH24:MI:SS') AS "Data da Partida"
FROM partida p 
WHERE p.nome LIKE '%a' AND LENGTH(p.nome) >= 7 and 
p.valor_ingresso < (select avg (valor_ingresso) from partida );

--8) Verifique se o torcedor ‘Fulano’ está cadastrado. Retorne verdadeiro caso esteja cadastrado e
--falso caso não esteja.

select count(*) > 0 as "conta fulano"
from torcedor
where nome = 'Fulano';


--9) No sistema existem diversas jogadoras cadastradas, porém foi solicitado dados somente das
--posições Goleira, Volante, Atacante e Lateral. Com base no que foi informado, selecione a média
--salarial das jogadoras das posições solicitadas. A saída deve ser renomeada.

select  AVG(salario) AS "Media Salarial das jogadoras das posições Goleira, Volante, Atacante e Lateral"
from jogador  
where posicao  in('Goleira','Volante', 'Atacante', 'Lateral');



