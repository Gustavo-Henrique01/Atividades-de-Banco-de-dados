

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



--1) Crie uma função que retorne os dados das seleções (todos os dados da tabela selecao). Mostre
--como utilizar a função.

select *
from selecao;

create or replace function ex1_lista8()
returns setof selecao as $$
declare
	sel selecao%rowtype;
begin
	for sel in select * from selecao loop
		return next sel;
	end loop;	
end;
$$ language plpgsql;


select * from ex1_lista8();

---2) Crie uma função que retorne os dados da seleção informando o nome do País (todos os dados da tabela selecao). Mostre como utilizar a função.

create or replace function ex2_lista8( nome_pais varchar)
returns setof selecao as $$
declare
	sel selecao%rowtype;
begin
	for sel in select * from selecao 
				where pais ilike nome_pais  
	loop
		return next sel;
	end loop;	
end;
$$ language plpgsql;

select * from ex2_lista8('Brasil');



--3) Crie uma função que retorne os dados das jogadoras de uma seleção, o nome da seleção deve ser informada como entrada da função (todos os dados da tabela jogador devem retornar como
--saída). Mostre como utilizar a função.

create or replace function ex3_lista8( nome_selecao varchar)
returns setof jogador as $$
declare
	jog jogador%rowtype;
	cod_selecao integer;
begin
	
	select sel.codigo into cod_selecao
	from selecao sel
	where sel.nome ilike nome_selecao;
	
	for jog in select * from jogador 
				where codigo_selecao = cod_selecao
	loop
		return next jog;
	end loop;	
end;
$$ language plpgsql;

select * from ex3_lista8('%bra%');




--4) Crie uma função que receba como entrada o nome de uma seleção, nome do novo torcedor, a
--data_nascimento, renda e genero. A sua função deve fazer a inserção deste novo torcedor no banco
--de dados. Não esqueça de descobrir o código da seleção, considere que a seleção já está
---cadastrada no banco de dados. A função não possui retorno (void). Mostre como utilizar a função.


create or replace function inserir_novo_torcedor(
    nome_selecao varchar(50),
    nome_torcedor varchar(50),
    data_nascimento_torcedor date,
    renda_torcedor numeric(20,2),
    genero_torcedor genero_enum
)
returns void as $$
declare
    codigo_selecao_torcedor int;
begin
    -- Obtém o código da seleção pelo nome
    select codigo into codigo_selecao_torcedor from selecao where nome = nome_selecao;

    -- Insere o novo torcedor
    insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
    values(nome_torcedor, data_nascimento_torcedor, renda_torcedor, genero_torcedor, codigo_selecao_torcedor);
end;
$$ language plpgsql;

select * from inserir_novo_torcedor('Brasileira', 'zézin', '1990-01-01', 100000, 'masculino');


--5) Crie uma função que receba como entrada o valor de aumento dos ingressos de uma partida e o
--nome do estádio da partida. Aplique o aumento no valor do ingresso das partidas que ocorreram no
--estádio informado. Mostre como utilizar a função.

create or replace function aumentar_valor_ingresso_partida(
    aumento numeric(8,2),
    nome_estadio varchar(50)
)
returns void as $$
begin
    
    update partida
    set valor_ingresso = valor_ingresso + aumento
    where codigo_estadio = (select codigo from estadio where nome = nome_estadio);
end;
$$ language plpgsql;

select aumentar_valor_ingresso_partida(500, 'Maracanã');


--6) Crie uma função que faça a inserção de uma nova seleção, caso ela ainda não exista (considere
--que cada seleção possui um nome distinto). Se a seleção for cadastrada com sucesso a função
--deve retornar verdadeiro, caso a seleção exista, a função deve retornar falso. Mostre como utilizar a
--função. Dicas: utilizar EXISTS e ver a sintaxe do IF/ELSE.


create or replace function inserir_nova_selecao(
    nome_selecao varchar(50),
    pais_selecao varchar(50),
    genero_selecao genero_enum
)
returns boolean as $$
declare
    selecao_existe boolean;
begin
    -- Verifica se a seleção já existe
    select exists(select 1 from selecao where nome = nome_selecao) into selecao_existe;

    -- Se a seleção não existe, insere e retorna verdadeiro
    if not selecao_existe then
        insert into selecao(nome, pais, genero)
        values(nome_selecao, pais_selecao, genero_selecao);
        return true;
    else
        -- Se a seleção já existe, retorna falso
        return false;
    end if;
end;
$$ language plpgsql;


select inserir_nova_selecao('Argentina', 'Argentina', 'masculino');

select inserir_nova_selecao('Brasileira', 'Brasil', 'feminino');
