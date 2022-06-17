
Функция АктивныеЗапросыНаSQLСервере(СерверSQL, МинДлительность = Неопределено) Экспорт
	
	ТекстЗапроса_SQL =
	"SELECT 
	|	sqltext.TEXT AS [sql_text],
	|	req.session_id AS [session],
	|	req.status AS [status],
	|	req.command AS [commad],
	|	req.cpu_time/1000 AS [CPU],
	|	req.start_time as [start_time],
	|	req.total_elapsed_time/1000 AS [duration],
	|	qerPlan.query_plan AS [plan_text]
	|FROM sys.dm_exec_requests req
	|	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
	|	CROSS APPLY sys.dm_exec_query_plan(req.plan_handle) qerPlan";
	
	Если МинДлительность <> Неопределено
		И МинДлительность > 0
		Тогда
		
		ТекстЗапроса_SQL = ТекстЗапроса_SQL + "
		|
		|WHERE
		|	req.total_elapsed_time >= " + Формат(МинДлительность*1000, "ЧГ=");
		
	КонецЕсли;
	
	ТекстЗапроса_SQL = ТекстЗапроса_SQL + "
	|
	|ORDER BY
	|	req.total_elapsed_time desc";
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL);
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса_SQL);
	ТЧ_SQL = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet);
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Возврат ТЧ_SQL;
	
КонецФункции

Функция АктивныеТранзакцииНаSQLСервере(СерверSQL) Экспорт
	
	ТекстЗапроса_SQL =
	"DECLARE @curr_date as DATETIME
	|
	|SET @curr_date = GETDATE()
	|
	|select
	|	SESSION_TRAN.session_id AS [session],
	|	SESSION_TRAN.transaction_id as [transaction],
	|	
	|	TRAN_INFO.transaction_begin_time AS [start_time],
	|	DateDiff(second, TRAN_INFO.transaction_begin_time, @curr_date) AS [duration],
	|	CASE   
	|      WHEN TRAN_INFO.transaction_type = 1 THEN 'read-write'
	|	  WHEN TRAN_INFO.transaction_type = 1 THEN 'read-only'
	|	  WHEN TRAN_INFO.transaction_type = 1 THEN 'system'
	|	  WHEN TRAN_INFO.transaction_type = 1 THEN 'distributed'
	|	  ELSE 'unknown'
	|	END as [type],
	|	
	|	CASE   
	|      WHEN TRAN_INFO.transaction_state = 0 THEN 'new'
	|      WHEN TRAN_INFO.transaction_state = 1 THEN 'initialized'
	|	  WHEN TRAN_INFO.transaction_state = 2 THEN 'active'
	|	  WHEN TRAN_INFO.transaction_state = 3 THEN 'ended'
	|	  WHEN TRAN_INFO.transaction_state = 4 THEN 'commit_begin'
	|	  WHEN TRAN_INFO.transaction_state = 5 THEN 'commit'
	|	  WHEN TRAN_INFO.transaction_state = 6 THEN 'commit_done'
	|	  WHEN TRAN_INFO.transaction_state = 7 THEN 'rollback'
	|	  WHEN TRAN_INFO.transaction_state = 8 THEN 'rollback_done'
	|	  ELSE 'unknown'
	|	END as [state],
	|
	|	CONN_INFO.num_reads AS num_reads,
	|	CONN_INFO.num_writes AS num_writes,
	|	CONN_INFO.last_read AS last_read,
	|	CONN_INFO.last_write AS last_write,
	|	CONN_INFO.client_net_address AS client_ip,
	|	
	|	SQL_TEXT.dbid,
	|	db_name(SQL_TEXT.dbid) AS ib_name,
	|	SQL_TEXT.text AS [sql_text],
	|	
	//|	QUERIES_INFO.start_time,
	|	QUERIES_INFO.status,
	|	QUERIES_INFO.command,
	|	QUERIES_INFO.wait_type,
	|	QUERIES_INFO.wait_time
	//|,
	//|	PLAN_INFO.query_plan as [plan_text]
	|
	|FROM sys.dm_tran_session_transactions AS SESSION_TRAN
	|	JOIN sys.dm_tran_active_transactions AS TRAN_INFO
	|		ON SESSION_TRAN.transaction_id = TRAN_INFO.transaction_id
	|	LEFT JOIN sys.dm_exec_connections AS CONN_INFO
	|		ON SESSION_TRAN.session_id = CONN_INFO.session_id
	|	CROSS APPLY sys.dm_exec_sql_text(CONN_INFO.most_recent_sql_handle) AS SQL_TEXT
	|	LEFT JOIN sys.dm_exec_requests AS QUERIES_INFO
	|		ON SESSION_TRAN.session_id = QUERIES_INFO.session_id
	//|	LEFT JOIN (
	//|		SELECT
	//|			VL_SESSION_TRAN.session_id AS session_id,
	//|			VL_PLAN_INFO.query_plan AS query_plan
	//|		FROM sys.dm_tran_session_transactions AS VL_SESSION_TRAN
	//|		INNER JOIN sys.dm_exec_requests AS VL_QUERIES_INFO
	//|			ON VL_SESSION_TRAN.session_id = VL_QUERIES_INFO.session_id
	//|		CROSS APPLY sys.dm_exec_text_query_plan(VL_QUERIES_INFO.plan_handle, VL_QUERIES_INFO.statement_start_offset, VL_QUERIES_INFO.statement_end_offset) AS VL_PLAN_INFO
	//|	) AS PLAN_INFO
	//|		ON SESSION_TRAN.session_id = PLAN_INFO.session_id
	|
	|ORDER BY transaction_begin_time ASC
	|";
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL);
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса_SQL);
	ТЧ_SQL = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet);
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Возврат ТЧ_SQL;
	
КонецФункции

Процедура Регламент_СборДанныхSQL() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НастройкиСбораДанныхSQL.СерверSQL КАК СерверSQL,
	|	НастройкиСбораДанныхSQL.АктивныеЗапросы КАК АктивныеЗапросы,
	|	НастройкиСбораДанныхSQL.АктивныеТранзакции КАК АктивныеТранзакции,
	|	НастройкиСбораДанныхSQL.ДлительностьЗапросовОт КАК ДлительностьЗапросовОт,
	|	НастройкиСбораДанныхSQL.ДлительностьТранзакцийОт КАК ДлительностьТранзакцийОт
	|ИЗ
	|	РегистрСведений.НастройкиСбораДанныхSQL КАК НастройкиСбораДанныхSQL
	|ГДЕ
	|	(НастройкиСбораДанныхSQL.АктивныеЗапросы
	|			ИЛИ НастройкиСбораДанныхSQL.АктивныеТранзакции)
	|	И НЕ НастройкиСбораДанныхSQL.СерверSQL.ПометкаУдаления";
	
	ВыборкаСерверов = Запрос.Выполнить().Выбрать();
	Пока ВыборкаСерверов.Следующий() Цикл
		Регламент_СобратьДанныеОСервереSQL(ВыборкаСерверов);
	КонецЦикла;
	
КонецПроцедуры

Процедура Регламент_СобратьДанныеОСервереSQL(ВыборкаСерверов)
	
	Если ВыборкаСерверов.АктивныеЗапросы Тогда
		Регламент_СобратьДанныеОСервереSQL_АктивныеЗапросы(ВыборкаСерверов.СерверSQL, ВыборкаСерверов.ДлительностьЗапросовОт);
	КонецЕсли;
	
	Если ВыборкаСерверов.АктивныеТранзакции Тогда
		Регламент_СобратьДанныеОСервереSQL_АктивныеТранзакции(ВыборкаСерверов.СерверSQL, ВыборкаСерверов.ДлительностьТранзакцийОт);
	КонецЕсли;
	
КонецПроцедуры



Процедура Регламент_СобратьДанныеОСервереSQL_АктивныеЗапросы(СерверSQL, ДлительностьЗапросовОт) Экспорт
	
	СохранятьПланыЗапросовSQL = Константы.СохранятьПланыЗапросовSQL.Получить();
	
	//ТекДата = ТекущаяУниверсальнаяДата();
	ТекДата = ТекущаяДатаСеанса();
	
	ТЧЗапросов = АктивныеЗапросыНаSQLСервере(СерверSQL, ДлительностьЗапросовОт);
	Для Каждого ОписаниеЗапросаSQL Из ТЧЗапросов Цикл
		
		ДатаНачала = ОписаниеЗапросаSQL.start_time;
		
		ДанныеЗапроса = ДанныеЗапросаSQLВБазеПоТексту(ОписаниеЗапросаSQL.sql_text);
		
		//sql_text = ВалидныйТекстаЗапросаSQL(ОписаниеЗапросаSQL.sql_text);
		//sql_text_hash = ХэшТекстаЗапросаSQL(sql_text);
		sql_text_hash = ДанныеЗапроса.sql_text_hash;
		
		КлючЗаписи = КлючЗаписи_СобранныеЗапросы(ДатаНачала, СерверSQL, ОписаниеЗапросаSQL.session, sql_text_hash);
		ЕстьЗаписи = Истина;
		Если КлючЗаписи.ID = Неопределено Тогда
			КлючЗаписи.ID = Новый УникальныйИдентификатор();
			ЕстьЗаписи = Ложь;
		КонецЕсли;

		НЗ_Запросы = РегистрыСведений.СобранныеЗапросыSQL.СоздатьНаборЗаписей();
		НЗ_Запросы.Отбор.ДатаНачала.Установить(КлючЗаписи.ДатаНачала);
		НЗ_Запросы.Отбор.СерверSQL.Установить(КлючЗаписи.СерверSQL);
		НЗ_Запросы.Отбор.ID.Установить(КлючЗаписи.ID);
		
		Если ЕстьЗаписи Тогда
			НЗ_Запросы.Прочитать();
			Запись_Запросы = НЗ_Запросы[0];
		Иначе
			Запись_Запросы = НЗ_Запросы.Добавить();
			ЗаполнитьЗначенияСвойств(Запись_Запросы, КлючЗаписи);
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(Запись_Запросы, ОписаниеЗапросаSQL);
		
		//Запись_Запросы.sql_text = sql_text;
		Запись_Запросы.sql_text_hash = sql_text_hash;
		Если СохранятьПланыЗапросовSQL Тогда
			Запись_Запросы.sql_plan_hash = ДанныеПланаЗапросаSQLВБазе(ОписаниеЗапросаSQL.plan_text, sql_text_hash).sql_plan_hash;
		КонецЕсли;
		Запись_Запросы.ДатаОбновления = ТекДата;
		
		НЗ_Запросы.ОбменДанными.Загрузка = Истина;
		НЗ_Запросы.Записать(Истина);
		
	КонецЦикла;
	
	МЗ = РегистрыСведений.ДатыСобранныхЗапросовSQL.СоздатьМенеджерЗаписи();
	МЗ.СерверSQL = СерверSQL;
	МЗ.ДатаПоследнегоСбора = ТекДата;
	
	МЗ.Записать(Истина);
	
КонецПроцедуры

Функция КлючЗаписи_СобранныеЗапросы(ДатаНачала, СерверSQL, session, sql_text_hash)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	Запрос.УстановитьПараметр("session", session);
	Запрос.УстановитьПараметр("sql_text_hash", sql_text_hash);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СобранныеЗапросыSQL.ДатаНачала КАК ДатаНачала,
	|	СобранныеЗапросыSQL.СерверSQL КАК СерверSQL,
	|	СобранныеЗапросыSQL.ID КАК ID,
	|	СобранныеЗапросыSQL.session КАК session,
	|	СобранныеЗапросыSQL.sql_text_hash КАК sql_text_hash
	|ИЗ
	|	РегистрСведений.СобранныеЗапросыSQL КАК СобранныеЗапросыSQL
	|ГДЕ
	|	СобранныеЗапросыSQL.ДатаНачала = &ДатаНачала
	|	И СобранныеЗапросыSQL.СерверSQL = &СерверSQL
	|	И СобранныеЗапросыSQL.session = &session
	|	И СобранныеЗапросыSQL.sql_text_hash = &sql_text_hash";
	
	КлючЗаписи = Новый Структура("ДатаНачала, СерверSQL, ID",
		ДатаНачала,
		СерверSQL
		);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		//Если Выборка.session = session
		//	И Выборка.sql_text_hash = sql_text_hash
		//	//И Выборка.sql_text = sql_text
		//	Тогда
			
			КлючЗаписи.ID = Выборка.ID;
			Возврат КлючЗаписи;
		//КонецЕсли;
		
	КонецЦикла;
	
	Возврат КлючЗаписи;
	
КонецФункции



Процедура Регламент_СобратьДанныеОСервереSQL_АктивныеТранзакции(СерверSQL, ДлительностьЗапросовОт) Экспорт
	
	//ТекДата = ТекущаяУниверсальнаяДата();
	ТекДата = ТекущаяДатаСеанса();
	
	ТЧЗапросов = АктивныеТранзакцииНаSQLСервере(СерверSQL);
	Для Каждого ОписаниеЗапросаSQL Из ТЧЗапросов Цикл
		
		Если ДлительностьЗапросовОт <> Неопределено
			И ДлительностьЗапросовОт > 0
			И ОписаниеЗапросаSQL.duration < ДлительностьЗапросовОт Тогда
			
			Продолжить;
		КонецЕсли;
		
		ДанныеЗапроса = ДанныеЗапросаSQLВБазеПоТексту(ОписаниеЗапросаSQL.sql_text);		
		
		ДатаНачала = ОписаниеЗапросаSQL.start_time;
		//sql_text = ВалидныйТекстаЗапросаSQL(ОписаниеЗапросаSQL.sql_text);
		//sql_text_hash = ХэшТекстаЗапросаSQL(sql_text);
		sql_text_hash = ДанныеЗапроса.sql_text_hash;
		
		КлючЗаписи = КлючЗаписи_СобранныеТранзакции(ДатаНачала, СерверSQL, ОписаниеЗапросаSQL.session, sql_text_hash);
		ЕстьЗаписи = Истина;
		Если КлючЗаписи.ID = Неопределено Тогда
			КлючЗаписи.ID = Новый УникальныйИдентификатор();
			ЕстьЗаписи = Ложь;
		КонецЕсли;

		НЗ_Запросы = РегистрыСведений.СобранныеТранзакцииSQL.СоздатьНаборЗаписей();
		НЗ_Запросы.Отбор.ДатаНачала.Установить(КлючЗаписи.ДатаНачала);
		НЗ_Запросы.Отбор.СерверSQL.Установить(КлючЗаписи.СерверSQL);
		НЗ_Запросы.Отбор.ID.Установить(КлючЗаписи.ID);
		
		Если ЕстьЗаписи Тогда
			НЗ_Запросы.Прочитать();
			Запись_Запросы = НЗ_Запросы[0];
		Иначе
			Запись_Запросы = НЗ_Запросы.Добавить();
			ЗаполнитьЗначенияСвойств(Запись_Запросы, КлючЗаписи);
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(Запись_Запросы, ОписаниеЗапросаSQL);

		//Запись_Запросы.sql_text = sql_text;
		Запись_Запросы.sql_text_hash = sql_text_hash;
		Запись_Запросы.ДатаОбновления = ТекДата;
		
		НЗ_Запросы.ОбменДанными.Загрузка = Истина;
		НЗ_Запросы.Записать(Истина);
		
	КонецЦикла;

	МЗ = РегистрыСведений.ДатыСобранныхТранзакцийSQL.СоздатьМенеджерЗаписи();
	МЗ.СерверSQL = СерверSQL;
	МЗ.ДатаПоследнегоСбора = ТекДата;
	
	МЗ.Записать(Истина);

КонецПроцедуры

Функция КлючЗаписи_СобранныеТранзакции(ДатаНачала, СерверSQL, session, sql_text_hash)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	Запрос.УстановитьПараметр("session", session);
	Запрос.УстановитьПараметр("sql_text_hash", sql_text_hash);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СобранныеЗапросыSQL.ДатаНачала КАК ДатаНачала,
	|	СобранныеЗапросыSQL.СерверSQL КАК СерверSQL,
	|	СобранныеЗапросыSQL.ID КАК ID,
	|	СобранныеЗапросыSQL.session КАК session,
	|	СобранныеЗапросыSQL.sql_text_hash КАК sql_text_hash
	|ИЗ
	|	РегистрСведений.СобранныеТранзакцииSQL КАК СобранныеЗапросыSQL
	|ГДЕ
	|	СобранныеЗапросыSQL.ДатаНачала = &ДатаНачала
	|	И СобранныеЗапросыSQL.СерверSQL = &СерверSQL
	|	И СобранныеЗапросыSQL.session = &session
	|	И СобранныеЗапросыSQL.sql_text_hash = &sql_text_hash";
	
	КлючЗаписи = Новый Структура("ДатаНачала, СерверSQL, ID",
		ДатаНачала,
		СерверSQL
		);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		//Если Выборка.session = session
		//	И Выборка.sql_text_hash = sql_text_hash
		//	//И Выборка.sql_text = sql_text
		//	Тогда
			
			КлючЗаписи.ID = Выборка.ID;
			Возврат КлючЗаписи;
		//КонецЕсли;
		
	КонецЦикла;
	
	Возврат КлючЗаписи;
	
КонецФункции




Функция ХэшТекстаЗапросаSQL(sql_text) Экспорт
	
	ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.SHA256);
	ХешированиеДанных.Добавить(sql_text);
	
	Возврат СтрЗаменить(ХешированиеДанных.ХешСумма, " ", "");
	
КонецФункции

Функция ВалидныйТекстаЗапросаSQL(Знач sql_text) Экспорт
	
	sql_text = СокрЛП(sql_text);
	
	sql_text = СтрЗаменить(sql_text, Символы.ПС, " ");
	sql_text = СтрЗаменить(sql_text, Символы.ПФ, " ");
	sql_text = СтрЗаменить(sql_text, Символы.Таб, " ");
	sql_text = СтрЗаменить(sql_text, Символы.ВТаб, " ");
	sql_text = СтрЗаменить(sql_text, Символы.НПП, " ");
	
	sql_text = СтрЗаменить(sql_text, "     ", " ");
	sql_text = СтрЗаменить(sql_text, "   ", " ");
	sql_text = СтрЗаменить(sql_text, "  ", " ");
	sql_text = СтрЗаменить(sql_text, "  ", " ");
	
	
	МассивИменТаблиц = Новый Массив;
	
	КодСимвола9 = КодСимвола("9");
	КодСимвола0 = КодСимвола("0");
	
	НомерТаблицы = 1;
	
	Позиция = СтрНайти(sql_text, "#tt");
	Пока Позиция > 0 Цикл
		
		Позиция = Позиция;
		Инд = 3;
		Пока Инд < 10 Цикл
			
			Симв = Сред(sql_text, Позиция + Инд, 1);
			
			Если КодСимвола(Симв) < КодСимвола0
				ИЛИ КодСимвола(Симв) > КодСимвола9 Тогда
				Прервать;
			КонецЕсли;
			
			Инд =  Инд + 1;
			
		КонецЦикла;
		
		sql_text = Лев(sql_text, Позиция+2) + Формат(НомерТаблицы, "ЧГ=") + Сред(sql_text, Позиция+Инд);
		НомерТаблицы = НомерТаблицы + 1;
		
		Позиция = СтрНайти(sql_text, "#tt",, Позиция+2);
		
	КонецЦикла;
	
	Возврат sql_text;
	
КонецФункции

Функция ДанныеЗапросаSQLВБазеПоТексту(Знач ТекстЗапросаSQL, КешДанных = Неопределено) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ТекстЗапросаSQL) Тогда
		РезультатРаботы = Новый Структура("sql_text_hash", "");
		Возврат РезультатРаботы;
	КонецЕсли;
	
	sql_text = ВалидныйТекстаЗапросаSQL(ТекстЗапросаSQL);
	sql_text_hash = ХэшТекстаЗапросаSQL(sql_text);
	РезультатРаботы = Новый Структура("sql_text_hash", sql_text_hash);
	
	Если КешДанных <> Неопределено Тогда
		РезультатВКэше = КешДанных.Получить(sql_text_hash);
		Если РезультатВКэше <> Неопределено Тогда
			Возврат РезультатРаботы;
		КонецЕсли;
	КонецЕсли;
	
	ПроверитьСоздатьЗапросSQLВБазе(sql_text_hash, sql_text);
	
	Если КешДанных <> Неопределено Тогда
		КешДанных.Вставить(sql_text_hash, sql_text_hash);
	КонецЕсли;
	
	Возврат РезультатРаботы;
	
КонецФункции

Процедура ПроверитьСоздатьЗапросSQLВБазе(sql_text_hash, sql_text)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("sql_text_hash", sql_text_hash);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КомментарииПоТекстамSQLЗапросов.sql_text_hash КАК sql_text_hash
	|ИЗ
	|	РегистрСведений.КомментарииПоТекстамSQLЗапросов КАК КомментарииПоТекстамSQLЗапросов
	|ГДЕ
	|	КомментарииПоТекстамSQLЗапросов.sql_text_hash = &sql_text_hash";
	
	Если НЕ Запрос.Выполнить().Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.КомментарииПоТекстамSQLЗапросов");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.УстановитьЗначение("sql_text_hash", sql_text_hash);
	Блокировка.Заблокировать();
	
	Если Запрос.Выполнить().Пустой() Тогда
		
		НЗ = РегистрыСведений.КомментарииПоТекстамSQLЗапросов.СоздатьНаборЗаписей();
		НЗ.Отбор.sql_text_hash.Установить(sql_text_hash);
		
		СтрокаЗаписи = НЗ.Добавить();
		СтрокаЗаписи.sql_text_hash = sql_text_hash;
		СтрокаЗаписи.валидныйТекстЗапросаSQL = sql_text;
		СтрокаЗаписи.текстЗапросаSQL = sql_text;
		
		НЗ.ОбменДанными.Загрузка = Истина;
		НЗ.Записать(Истина);
		
	КонецЕсли;
	
	ЗафиксироватьТранзакцию();
	
КонецПроцедуры

Функция ДанныеПланаЗапросаSQLВБазе(Знач ТекстПланаЗапросаSQL, Знач sql_text_hash, КешДанных = Неопределено) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ТекстПланаЗапросаSQL) Тогда
		РезультатРаботы = Новый Структура("sql_plan_hash", "");
		Возврат РезультатРаботы;
	КонецЕсли;
	
	sql_plan_hash = ХэшТекстаЗапросаSQL(ТекстПланаЗапросаSQL);
	РезультатРаботы = Новый Структура("sql_plan_hash", sql_plan_hash);
	
	Если КешДанных <> Неопределено Тогда
		РезультатВКэше = КешДанных.Получить(sql_plan_hash);
		Если РезультатВКэше <> Неопределено Тогда
			Возврат РезультатРаботы;
		КонецЕсли;
	КонецЕсли;
	
	ПроверитьСоздатьПланЗапросаSQLВБазе(sql_text_hash, sql_plan_hash, ТекстПланаЗапросаSQL);
	
	Если КешДанных <> Неопределено Тогда
		КешДанных.Вставить(sql_plan_hash, sql_plan_hash);
	КонецЕсли;
	
	Возврат РезультатРаботы;
	
КонецФункции

Процедура ПроверитьСоздатьПланЗапросаSQLВБазе(sql_text_hash, sql_plan_hash, plan_text)

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("sql_text_hash", sql_text_hash);
	Запрос.УстановитьПараметр("sql_plan_hash", sql_plan_hash);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПланыЗапросовSQL.sql_text_hash КАК sql_text_hash
	|ИЗ
	|	РегистрСведений.ПланыЗапросовSQL КАК ПланыЗапросовSQL
	|ГДЕ
	|	ПланыЗапросовSQL.sql_text_hash = &sql_text_hash
	|	И ПланыЗапросовSQL.sql_plan_hash = &sql_plan_hash";
	
	Если НЕ Запрос.Выполнить().Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ПланыЗапросовSQL");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.УстановитьЗначение("sql_text_hash", sql_text_hash);
	ЭлементБлокировки.УстановитьЗначение("sql_plan_hash", sql_plan_hash);
	Блокировка.Заблокировать();
	
	Если Запрос.Выполнить().Пустой() Тогда
		
		НЗ = РегистрыСведений.ПланыЗапросовSQL.СоздатьНаборЗаписей();
		НЗ.Отбор.sql_text_hash.Установить(sql_text_hash);
		НЗ.Отбор.sql_plan_hash.Установить(sql_plan_hash);
		
		СтрокаЗаписи = НЗ.Добавить();
		СтрокаЗаписи.sql_text_hash = sql_text_hash;
		СтрокаЗаписи.sql_plan_hash = sql_plan_hash;
		СтрокаЗаписи.plan_text = plan_text;
		
		НЗ.ОбменДанными.Загрузка = Истина;
		НЗ.Записать(Истина);
		
	КонецЕсли;
	
	ЗафиксироватьТранзакцию();
	
КонецПроцедуры



Процедура Регламент_СборСтатискиЗапросовSQL() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НастройкиСбораДанныхSQL.СерверSQL КАК СерверSQL
	|ИЗ
	|	РегистрСведений.НастройкиСбораДанныхSQL КАК НастройкиСбораДанныхSQL
	|ГДЕ
	|	НастройкиСбораДанныхSQL.СобиратьСтатистикуЗапросов
	|	И НЕ НастройкиСбораДанныхSQL.СерверSQL.ПометкаУдаления";
	
	ВыборкаСерверов = Запрос.Выполнить().Выбрать();
	Пока ВыборкаСерверов.Следующий() Цикл
		СобратьДанныеОСтатистикеНаСервереSQL(ВыборкаСерверов);
	КонецЦикла;
	
КонецПроцедуры

Процедура СобратьДанныеОСтатистикеНаСервереSQL(ВыборкаСерверов)
	
	СохранятьПланыЗапросовSQL = Константы.СохранятьПланыЗапросовSQL.Получить();
	
	ДатаСбора = ТекущаяДатаСеанса();
	
	ТЧ_SQL = РегистрыСведений.СтатистикаПоЗапросамSQL.СоздатьНаборЗаписей().ВыгрузитьКолонки();
	
	RecordSet = СтатистикаНаSQLСервере(ВыборкаСерверов.СерверSQL);
	
	Если НЕ РаботаСSQLСервером.ВВыборкеЕстьЗаписи(RecordSet) Тогда
		RecordSet.Close();
		Возврат;
	КонецЕсли;
	
	КэшДанных = ПолныйКэшЗапросов();
	КэшДанныхПланов = ПолныйКэшПланов();

	Попытка
		ИменаПолей = "dbname,creation_time,last_execution_time,execution_count,total_worker_time,last_worker_time,min_worker_time,max_worker_time,plan_generation_num,total_physical_reads";
		ИменаПолей = ИменаПолей + ",min_physical_reads,max_physical_reads,total_logical_reads,min_logical_reads,max_logical_reads,total_logical_writes,min_logical_writes,max_logical_writes";
		ИменаПолей = ИменаПолей + ",total_elapsed_time,min_elapsed_time,max_elapsed_time,total_rows,last_rows,min_rows,max_rows,total_dop,last_dop,min_dop,max_dop";	
		
		Сч = 0;
		
		Пока РаботаСSQLСервером.СледующаяЗаписьВыборки(RecordSet) Цикл
			
			Сч = Сч + 1;
			
			sql_text = RecordSet.Fields("text").Value;
			Если sql_text = null Тогда
				Продолжить;
			КонецЕсли;
			
			СтрокаТЧ = ТЧ_SQL.Добавить();
			ЗначенияПолей = РаботаСSQLСервером.ЗначениеПолейВыборки(RecordSet, ИменаПолей);
			ЗаполнитьЗначенияСвойств(СтрокаТЧ, ЗначенияПолей);
			
			СтрокаТЧ.sql_text_hash = ДанныеЗапросаSQLВБазеПоТексту(sql_text, КэшДанных).sql_text_hash;
			Если СохранятьПланыЗапросовSQL Тогда
				СтрокаТЧ.sql_plan_hash = ДанныеПланаЗапросаSQLВБазе(RecordSet.Fields("query_plan").Value, СтрокаТЧ.sql_text_hash, КэшДанныхПланов).sql_plan_hash;
			КонецЕсли;
			
			Попытка
				RecordSet.MoveNext();
			Исключение
				Прервать;
			КонецПопытки;
			
		КонецЦикла;
	
		RecordSet.Close();
	Исключение
		RecordSet.Close();
		ТекстОшибки = ОписаниеОшибки();
		ВызватьИсключение (ТекстОшибки);
	КонецПопытки;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТЧ_SQL", ТЧ_SQL);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	T.sql_text_hash КАК sql_text_hash,
	|	T.sql_plan_hash КАК sql_plan_hash,
	|	T.dbname КАК dbname,
	|	T.creation_time КАК creation_time,
	|	T.last_execution_time КАК last_execution_time,
	|	T.execution_count КАК execution_count,
	|	T.total_worker_time КАК total_worker_time,
	|	T.last_worker_time КАК last_worker_time,
	|	T.min_worker_time КАК min_worker_time,
	|	T.max_worker_time КАК max_worker_time,
	|	T.plan_generation_num КАК plan_generation_num,
	|	T.total_physical_reads КАК total_physical_reads,
	|	T.min_physical_reads КАК min_physical_reads,
	|	T.max_physical_reads КАК max_physical_reads,
	|	T.total_logical_reads КАК total_logical_reads,
	|	T.min_logical_reads КАК min_logical_reads,
	|	T.max_logical_reads КАК max_logical_reads,
	|	T.total_logical_writes КАК total_logical_writes,
	|	T.min_logical_writes КАК min_logical_writes,
	|	T.max_logical_writes КАК max_logical_writes,
	|	T.total_elapsed_time КАК total_elapsed_time,
	|	T.min_elapsed_time КАК min_elapsed_time,
	|	T.max_elapsed_time КАК max_elapsed_time,
	|	T.total_rows КАК total_rows,
	|	T.last_rows КАК last_rows,
	|	T.min_rows КАК min_rows,
	|	T.max_rows КАК max_rows,
	|	T.total_dop КАК total_dop,
	|	T.last_dop КАК last_dop,
	|	T.min_dop КАК min_dop,
	|	T.max_dop КАК max_dop
	|ПОМЕСТИТЬ ВТ_СтатистикаSQL
	|ИЗ
	|	&ТЧ_SQL КАК T
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	sql_text_hash
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_СтатистикаSQL.sql_text_hash КАК sql_text_hash,
	|	ВТ_СтатистикаSQL.dbname КАК dbname,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.sql_plan_hash) КАК sql_plan_hash,
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВТ_СтатистикаSQL.sql_plan_hash) КАК ВариантовЗапроса,
	|	МИНИМУМ(ВТ_СтатистикаSQL.creation_time) КАК creation_time,
	|	СУММА(ВТ_СтатистикаSQL.plan_generation_num) КАК plan_generation_num,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.last_execution_time) КАК last_execution_time,
	|	СУММА(ВТ_СтатистикаSQL.execution_count) КАК execution_count,
	|	СУММА(ВТ_СтатистикаSQL.total_worker_time) КАК total_worker_time,
	|	СУММА(ВТ_СтатистикаSQL.total_physical_reads) КАК total_physical_reads,
	|	СУММА(ВТ_СтатистикаSQL.total_logical_reads) КАК total_logical_reads,
	|	СУММА(ВТ_СтатистикаSQL.total_logical_writes) КАК total_logical_writes,
	|	СУММА(ВТ_СтатистикаSQL.total_elapsed_time) КАК total_elapsed_time,
	|	СУММА(ВТ_СтатистикаSQL.total_rows) КАК total_rows,
	|	СУММА(ВТ_СтатистикаSQL.total_dop) КАК total_dop,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.last_worker_time) КАК last_worker_time,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.last_rows) КАК last_rows,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.last_dop) КАК last_dop,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_worker_time) КАК min_worker_time,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_physical_reads) КАК min_physical_reads,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_logical_reads) КАК min_logical_reads,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_logical_writes) КАК min_logical_writes,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_elapsed_time) КАК min_elapsed_time,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_rows) КАК min_rows,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_dop) КАК min_dop,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_worker_time) КАК max_worker_time,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_physical_reads) КАК max_physical_reads,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_logical_reads) КАК max_logical_reads,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_logical_writes) КАК max_logical_writes,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_elapsed_time) КАК max_elapsed_time,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_rows) КАК max_rows,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_dop) КАК max_dop
	|ИЗ
	|	ВТ_СтатистикаSQL КАК ВТ_СтатистикаSQL
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ_СтатистикаSQL.sql_text_hash,
	|	ВТ_СтатистикаSQL.dbname";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Сч = 0;
	КолВсего = Выборка.Количество();
	
	НачатьТранзакцию();
	
	Пока Выборка.Следующий() Цикл
		
		НЗ = РегистрыСведений.СтатистикаПоЗапросамSQL.СоздатьНаборЗаписей();
		НЗ.Отбор.СерверSQL.Установить(ВыборкаСерверов.СерверSQL);
		НЗ.Отбор.ДатаСбора.Установить(ДатаСбора);
		НЗ.Отбор.sql_text_hash.Установить(Выборка.sql_text_hash);
		НЗ.Отбор.dbname.Установить(Выборка.dbname);
		
		СтрокаНЗ = НЗ.Добавить();
		
		ЗаполнитьЗначенияСвойств(СтрокаНЗ, Выборка);
		
		СтрокаНЗ.СерверSQL		= ВыборкаСерверов.СерверSQL;
		СтрокаНЗ.ДатаСбора		= ДатаСбора;
		СтрокаНЗ.sql_text_hash	= Выборка.sql_text_hash;
		СтрокаНЗ.dbname	= Выборка.dbname;
		
		НЗ.ОбменДанными.Загрузка = Истина;
		НЗ.Записать(Ложь);
		
		Сч = Сч + 1;
		
		Если Сч % 200 = 0 Тогда
			ЗафиксироватьТранзакцию();
			НачатьТранзакцию();
		КонецЕсли;
		
	КонецЦикла;
	
	ЗафиксироватьТранзакцию();
	
	ОбновитьОбщиеДанныеОСтатистикеНаСервереSQL(ВыборкаСерверов.СерверSQL, ДатаСбора);
	
КонецПроцедуры

Процедура ОбновитьОбщиеДанныеОСтатистикеНаСервереSQL(СерверSQL, ДатаСбора) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	Запрос.УстановитьПараметр("ДатаСбора", ДатаСбора);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СУММА(СтатистикаПоЗапросамSQL.total_elapsed_time) КАК total_elapsed_time,
	|	СУММА(СтатистикаПоЗапросамSQL.total_worker_time) КАК total_worker_time,
	|	СУММА(СтатистикаПоЗапросамSQL.total_physical_reads) КАК total_physical_reads,
	|	СУММА(СтатистикаПоЗапросамSQL.total_logical_reads) КАК total_logical_reads,
	|	СУММА(СтатистикаПоЗапросамSQL.total_logical_writes) КАК total_logical_writes,
	|	СтатистикаПоЗапросамSQL.СерверSQL КАК СерверSQL,
	|	СтатистикаПоЗапросамSQL.ДатаСбора КАК ДатаСбора
	|ИЗ
	|	РегистрСведений.СтатистикаПоЗапросамSQL КАК СтатистикаПоЗапросамSQL
	|ГДЕ
	|	СтатистикаПоЗапросамSQL.СерверSQL = &СерверSQL
	|	И СтатистикаПоЗапросамSQL.ДатаСбора = &ДатаСбора
	|
	|СГРУППИРОВАТЬ ПО
	|	СтатистикаПоЗапросамSQL.ДатаСбора,
	|	СтатистикаПоЗапросамSQL.СерверSQL";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		НЗ = РегистрыСведений.СтатистикаПоЗапросамSQLОбщиеДанные.СоздатьНаборЗаписей();
		НЗ.Отбор.СерверSQL.Установить(Выборка.СерверSQL);
		НЗ.Отбор.ДатаСбора.Установить(Выборка.ДатаСбора);
		
		СтрокаНЗ = НЗ.Добавить();
		
		ЗаполнитьЗначенияСвойств(СтрокаНЗ, Выборка);
		
		НЗ.Записать(Истина);
		
	КонецЦикла;
	
КонецПроцедуры


Функция ПолныйКэшЗапросов()
	
	КэшДанных = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КомментарииПоТекстамSQLЗапросов.sql_text_hash КАК sql_text_hash
	|ИЗ
	|	РегистрСведений.КомментарииПоТекстамSQLЗапросов КАК КомментарииПоТекстамSQLЗапросов";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		КэшДанных.Вставить(Выборка.sql_text_hash, Выборка.sql_text_hash);
	КонецЦикла;
	
	Возврат КэшДанных;
	
КонецФункции

Функция ПолныйКэшПланов()
	
	КэшДанных = Новый Соответствие;

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПланыЗапросовSQL.sql_text_hash КАК sql_text_hash,
	|	ПланыЗапросовSQL.sql_plan_hash КАК sql_plan_hash
	|ИЗ
	|	РегистрСведений.ПланыЗапросовSQL КАК ПланыЗапросовSQL";
	
	//КэшДанных = Запрос.Выполнить().Выгрузить();
	//КэшДанных.Индексы.Добавить("sql_plan_hash, sql_text_hash");
	//
	//Возврат КэшДанных;
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		КэшДанных.Вставить(Выборка.sql_plan_hash, Выборка.sql_plan_hash);
	КонецЦикла;
	
	Возврат КэшДанных;

КонецФункции

Функция СтатистикаНаSQLСервере(СерверSQL) Экспорт
	
	ЧасовПросматривать = Час(ТекущаяДатаСеанса())-9;
	
	ТекстЗапроса_SQL =
	"select top 10000000
	|	qp.query_plan,
	|	st.text,
	|	ISNULL(st.dbid,CONVERT(SMALLINT,att.value)) as dbid,
	|	dtb.name as dbname,
	|	qs.creation_time,
	|	qs.last_execution_time,
	|	qs.execution_count,
	|	qs.total_worker_time,
	|	qs.last_worker_time,
	|	qs.min_worker_time,
	|	qs.max_worker_time,
	|	qs.plan_generation_num,
	|	qs.total_physical_reads,
	|	qs.min_physical_reads,
	|	qs.max_physical_reads,
	|	qs.total_logical_reads,
	|	qs.min_logical_reads,
	|	qs.max_logical_reads,
	|	qs.total_logical_writes,
	|	qs.min_logical_writes,
	|	qs.max_logical_writes,
	|	qs.total_elapsed_time,
	|	qs.min_elapsed_time,
	|	qs.max_elapsed_time,
	|	qs.total_rows,
	|	qs.last_rows,
	|	qs.min_rows,
	|	qs.max_rows,
	|	qs.total_dop,
	|	qs.last_dop,
	|	qs.min_dop,
	|	qs.max_dop
	|FROM sys.dm_exec_query_stats qs
	|	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	|	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
	|	LEFT OUTER JOIN(
	|		SELECT DISTINCT
	|			qs.plan_handle,
	|			att.value
	|		FROM sys.dm_exec_query_stats qs
	|		CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) att
	|		WHERE
	|			att.attribute='dbid') as att
	|	ON
	|		qs.plan_handle = att.plan_handle
	|	LEFT OUTER JOIN sys.databases as dtb
	|	on ISNULL(st.dbid,CONVERT(SMALLINT,att.value)) = dtb.database_id
	|where
	|	qs.last_execution_time > (CURRENT_TIMESTAMP - '" + ЧасовПросматривать + ":00:00.000')
	|ORDER BY
	|	qs.total_worker_time desc";
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL,, 1200);
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса_SQL, 1200);
	
	Возврат RecordSet;
	
	//ТЧ_SQL = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet);
	//РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	//Возврат ТЧ_SQL;
	
КонецФункции


Функция СтатистикаОжиданийSQLСервера(СерверSQL)
	
	ТекстЗапроса_SQL =
	"SELECT
	|	[wait_type],
	|	CAST([wait_time_ms] / 1000.0 AS DECIMAL (17,0)) AS [wait_time_s],
	|	CAST([signal_wait_time_ms] / 1000.0 AS DECIMAL (17,0)) AS [signal_wait_time_s],
	|	[waiting_tasks_count] AS [waiting_tasks_count]
	|
	|	FROM sys.dm_os_wait_stats
	|	WHERE [wait_type] NOT IN (
	|        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
	|        N'BROKER_TASK_STOP', N'BROKER_TO_FLUSH',
	|        N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
	|        N'CHKPT', N'CLR_AUTO_EVENT',
	|        N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
	|        
	|        -- Maybe uncomment these four if you have mirroring issues
	|        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
	|        N'DBMIRROR_WORKER_QUEUE', N'DBMIRRORING_CMD',
	| 
	|        N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
	|        N'EXECSYNC', N'FSAGENT',
	|        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
	| 
	|        -- Maybe uncomment these six if you have AG issues
	|        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
	|        N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
	|        N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
	| 
	|        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP',
	|        N'LOGMGR_QUEUE', N'MEMORY_ALLOCATION_EXT',
	|        N'ONDEMAND_TASK_QUEUE',
	|        N'PREEMPTIVE_XE_GETTARGETSTATE',
	|        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
	|        N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
	|        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_ASYNC_QUEUE',
	|        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
	|        N'QDS_SHUTDOWN_QUEUE', N'REDO_THREAD_PENDING_WORK',
	|        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
	|        N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH',
	|        N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
	|        N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
	|        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP',
	|        N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
	|        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT',
	|        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
	|        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
	|        N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS',
	|        N'WAITFOR', N'WAITFOR_TASKSHUTDOWN',
	|        N'WAIT_XTP_RECOVERY',
	|        N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
	|        N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
	|        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT')
	|	AND [waiting_tasks_count] > 0
	|ORDER BY
	|	[wait_time_ms] desc";
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL,, 60);
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса_SQL, 60);
	
	ТЧ_SQL = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet);
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Возврат ТЧ_SQL;
	
КонецФункции


Процедура Регламент_СборСтатискиОжиданийSQL() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НастройкиСбораДанныхSQL.СерверSQL КАК СерверSQL
	|ИЗ
	|	РегистрСведений.НастройкиСбораДанныхSQL КАК НастройкиСбораДанныхSQL
	|ГДЕ
	|	НастройкиСбораДанныхSQL.СобиратьСтатистикуОжиданий
	|	И НЕ НастройкиСбораДанныхSQL.СерверSQL.ПометкаУдаления";
	
	ВыборкаСерверов = Запрос.Выполнить().Выбрать();
	Пока ВыборкаСерверов.Следующий() Цикл
		СобратьДанныеОСтатистикеОжиданийНаСервереSQL(ВыборкаСерверов.СерверSQL);
	КонецЦикла;
	
КонецПроцедуры

Процедура СобратьДанныеОСтатистикеОжиданийНаСервереSQL(СерверSQL)
	
	ДатаСбора = ТекущаяДатаСеанса();
	ТЧ_Ожиданий = СтатистикаОжиданийSQLСервера(СерверSQL);
	
	НачатьТранзакцию();
	Попытка
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.КэшСтатистикаПоОжиданиямSQL");
		ЭлементБлокировки.УстановитьЗначение("СерверSQL", СерверSQL);
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();

		ЗаписатьСобранныеДанныеОСтатистикеОжиданийНаСервереSQL(СерверSQL, ТЧ_Ожиданий, ДатаСбора);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение (ТекстОшибки);
	КонецПопытки;
	
КонецПроцедуры

Процедура ЗаписатьСобранныеДанныеОСтатистикеОжиданийНаСервереSQL(СерверSQL, ТЧ_Ожиданий, ДатаСбора)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КэшСтатистикаПоОжиданиямSQL.СерверSQL КАК СерверSQL,
	|	КэшСтатистикаПоОжиданиямSQL.wait_type КАК wait_type,
	|	КэшСтатистикаПоОжиданиямSQL.wait_time_s КАК wait_time_s,
	|	КэшСтатистикаПоОжиданиямSQL.signal_wait_time_s КАК signal_wait_time_s,
	|	КэшСтатистикаПоОжиданиямSQL.waiting_tasks_count КАК waiting_tasks_count,
	|	КэшСтатистикаПоОжиданиямSQL.ДатаСбора КАК ДатаСбора
	|ИЗ
	|	РегистрСведений.КэшСтатистикаПоОжиданиямSQL КАК КэшСтатистикаПоОжиданиямSQL
	|ГДЕ
	|	КэшСтатистикаПоОжиданиямSQL.СерверSQL = &СерверSQL";
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		ЗаписатьСтатистикуОжиданийВКэш(СерверSQL, ТЧ_Ожиданий, ДатаСбора);
		Возврат;
	КонецЕсли;
	
	ТЧ_Ожиданий_Кэш = РезультатЗапроса.Выгрузить();
	duration_s = (ДатаСбора - ТЧ_Ожиданий_Кэш[0].ДатаСбора);
	
	Если duration_s <= 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если duration_s > 36000 Тогда
		ЗаписатьСтатистикуОжиданийВКэш(СерверSQL, ТЧ_Ожиданий, ДатаСбора);
		Возврат;
	КонецЕсли;
	
	НЗ = РегистрыСведений.СтатистикаПоОжиданиямSQL.СоздатьНаборЗаписей();
	НЗ.Отбор.СерверSQL.Установить(СерверSQL);
	НЗ.Отбор.ДатаСбора.Установить(ДатаСбора);
	
	Для Каждого СтрокаОжиданий ИЗ ТЧ_Ожиданий Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаОжиданий.wait_time_s) Тогда
			Продолжить;
		КонецЕсли;
		
		wait_type = РаботаСSQLСерверомПовтИсп.ВидыОжиданийSQLПоИмени(СтрокаОжиданий.wait_type);
		
		СтрокиВКэше = ТЧ_Ожиданий_Кэш.НайтиСтроки(Новый Структура("wait_type", wait_type));
		Если СтрокиВКэше.Количество() = 0 Тогда
			СтрокаВКэше = Неопределено;
		Иначе
			СтрокаВКэше = СтрокиВКэше[0];
		КонецЕсли;
		
		НоваяСтрока = НЗ.Добавить();
		НоваяСтрока.СерверSQL = СерверSQL;
		НоваяСтрока.ДатаСбора = ДатаСбора;
		НоваяСтрока.wait_type = wait_type;
		
		НоваяСтрока.duration_s = duration_s;
		
		НоваяСтрока.wait_time_s			= ?(ЗначениеЗаполнено(СтрокаОжиданий.wait_time_s),			СтрокаОжиданий.wait_time_s, 0);
		НоваяСтрока.signal_wait_time_s	= ?(ЗначениеЗаполнено(СтрокаОжиданий.signal_wait_time_s),	СтрокаОжиданий.signal_wait_time_s, 0);
		НоваяСтрока.waiting_tasks_count	= ?(ЗначениеЗаполнено(СтрокаОжиданий.waiting_tasks_count),	СтрокаОжиданий.waiting_tasks_count, 0);
		
		Если СтрокаВКэше <> Неопределено Тогда
			НоваяСтрока.wait_time_s			= НоваяСтрока.wait_time_s			- ?(ЗначениеЗаполнено(СтрокаВКэше.wait_time_s),			СтрокаВКэше.wait_time_s, 0);
			НоваяСтрока.signal_wait_time_s	= НоваяСтрока.signal_wait_time_s	- ?(ЗначениеЗаполнено(СтрокаВКэше.signal_wait_time_s),	СтрокаВКэше.signal_wait_time_s, 0);
			НоваяСтрока.waiting_tasks_count	= НоваяСтрока.waiting_tasks_count	- ?(ЗначениеЗаполнено(СтрокаВКэше.waiting_tasks_count),	СтрокаВКэше.waiting_tasks_count, 0);
		КонецЕсли;
		
	КонецЦикла;
	
	НЗ.Записать(Ложь);
	
	ЗаписатьСтатистикуОжиданийВКэш(СерверSQL, ТЧ_Ожиданий, ДатаСбора);
	
КонецПроцедуры

Процедура ЗаписатьСтатистикуОжиданийВКэш(СерверSQL, ТЧ_Ожиданий, ДатаСбора)
	
	НЗ = РегистрыСведений.КэшСтатистикаПоОжиданиямSQL.СоздатьНаборЗаписей();
	НЗ.Отбор.СерверSQL.Установить(СерверSQL);
	
	Для Каждого СтрокаОжиданий ИЗ ТЧ_Ожиданий Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаОжиданий.wait_time_s) Тогда
			Продолжить;
		КонецЕсли;

		wait_type = РаботаСSQLСерверомПовтИсп.ВидыОжиданийSQLПоИмени(СтрокаОжиданий.wait_type);
		
		НоваяСтрока = НЗ.Добавить();
		НоваяСтрока.СерверSQL = СерверSQL;
		НоваяСтрока.wait_type = wait_type;
		
		НоваяСтрока.ДатаСбора			= ДатаСбора;
		НоваяСтрока.wait_time_s			= СтрокаОжиданий.wait_time_s;
		НоваяСтрока.signal_wait_time_s	= СтрокаОжиданий.signal_wait_time_s;
		НоваяСтрока.waiting_tasks_count	= СтрокаОжиданий.waiting_tasks_count;
		
	КонецЦикла;
	
	НЗ.Записать(Истина);
	
КонецПроцедуры

