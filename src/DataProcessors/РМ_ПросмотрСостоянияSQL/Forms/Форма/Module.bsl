

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьДанные_АктивныеЗапросыНаСервере(ТекДата)
	
	АктивныеЗапросы.Очистить();
	Если НЕ ЗначениеЗаполнено(СерверSQL) Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ДатыСобранныхЗапросовSQL.ДатаПоследнегоСбора КАК ДатаПоследнегоСбора
	|ИЗ
	|	РегистрСведений.ДатыСобранныхЗапросовSQL КАК ДатыСобранныхЗапросовSQL
	|ГДЕ
	|	ДатыСобранныхЗапросовSQL.СерверSQL = &СерверSQL";
	
	ДатаОбновления = Неопределено;
	ВыборкаДаты = Запрос.Выполнить().Выбрать();
	Если ВыборкаДаты.Следующий() Тогда
		ДатаОбновления = ВыборкаДаты.ДатаПоследнегоСбора;
	КонецЕсли;
	
	Если ДатаОбновления = Неопределено
		ИЛИ (ТекДата - ДатаОбновления) > 20 Тогда
		
		СборДанныхОПроизводительности.Регламент_СборДанныхSQL();
		
		ДатаОбновления = Неопределено;
		ВыборкаДаты = Запрос.Выполнить().Выбрать();
		Если ВыборкаДаты.Следующий() Тогда
			ДатаОбновления = ВыборкаДаты.ДатаПоследнегоСбора;
		КонецЕсли;
		
	КонецЕсли;
	
	Запрос.УстановитьПараметр("ДатаОбновления", ДатаОбновления);
	Запрос.УстановитьПараметр("ДатаНачала", ТекДата-43200);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СобранныеЗапросыSQL.ДатаНачала КАК ДатаНачала,
	|	СобранныеЗапросыSQL.СерверSQL КАК СерверSQL,
	|	СобранныеЗапросыSQL.ID КАК ID,
	|	СобранныеЗапросыSQL.session КАК session,
	|	СобранныеЗапросыSQL.status КАК status,
	|	СобранныеЗапросыSQL.commad КАК commad,
	|	СобранныеЗапросыSQL.CPU КАК CPU,
	|	СобранныеЗапросыSQL.duration КАК duration,
	|	СобранныеЗапросыSQL.sql_text_hash КАК sql_text_hash,
	|	СобранныеЗапросыSQL.ДатаОбновления КАК ДатаОбновления,
	|	КомментарииПоТекстамSQLЗапросов.текстЗапросаSQL КАК текстЗапросаSQL,
	|	КомментарииПоТекстамSQLЗапросов.текстЗапроса1С КАК текстЗапроса1С,
	|	КомментарииПоТекстамSQLЗапросов.Комментарий КАК КомментарийПоЗапросу
	|ИЗ
	|	РегистрСведений.СобранныеЗапросыSQL КАК СобранныеЗапросыSQL
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КомментарииПоТекстамSQLЗапросов КАК КомментарииПоТекстамSQLЗапросов
	|		ПО СобранныеЗапросыSQL.sql_text_hash = КомментарииПоТекстамSQLЗапросов.sql_text_hash
	|ГДЕ
	|	СобранныеЗапросыSQL.СерверSQL = &СерверSQL
	|	И СобранныеЗапросыSQL.ДатаНачала > &ДатаНачала
	|	И СобранныеЗапросыSQL.ДатаОбновления = &ДатаОбновления";
	
	ТЧ_SQL = Запрос.Выполнить().Выгрузить();
	Для Каждого Строка_SQL Из ТЧ_SQL Цикл
		
		НоваяСтрока = АктивныеЗапросы.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка_SQL);
		
	КонецЦикла;
	
	ДатаОбновленияЗапросы = МестноеВремя(ДатаОбновления, ЧасовойПоясСеанса());
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьДанные_ТранзакцииНаСервере(ТекДата)
	
	АктивныеТранзакции.Очистить();
	Если НЕ ЗначениеЗаполнено(СерверSQL) Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ДатыСобранныхТранзакцийSQL.ДатаПоследнегоСбора КАК ДатаПоследнегоСбора
	|ИЗ
	|	РегистрСведений.ДатыСобранныхТранзакцийSQL КАК ДатыСобранныхТранзакцийSQL
	|ГДЕ
	|	ДатыСобранныхТранзакцийSQL.СерверSQL = &СерверSQL";
	
	ДатаОбновления = Неопределено;
	ВыборкаДаты = Запрос.Выполнить().Выбрать();
	Если ВыборкаДаты.Следующий() Тогда
		ДатаОбновления = ВыборкаДаты.ДатаПоследнегоСбора;
	КонецЕсли;
	
	Если ДатаОбновления = Неопределено Тогда
		
		СборДанныхОПроизводительности.Регламент_СборДанныхSQL();
		
		ДатаОбновления = Неопределено;
		ВыборкаДаты = Запрос.Выполнить().Выбрать();
		Если ВыборкаДаты.Следующий() Тогда
			ДатаОбновления = ВыборкаДаты.ДатаПоследнегоСбора;
		КонецЕсли;
		
	КонецЕсли;
	
	Запрос.УстановитьПараметр("ДатаОбновления", ДатаОбновления);
	Запрос.УстановитьПараметр("ДатаНачала", ТекДата-43200);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СобранныеТранзакцииSQL.ДатаНачала КАК ДатаНачала,
	|	СобранныеТранзакцииSQL.СерверSQL КАК СерверSQL,
	|	СобранныеТранзакцииSQL.ID КАК ID,
	|	СобранныеТранзакцииSQL.session КАК session,
	|	СобранныеТранзакцииSQL.duration КАК duration,
	|	СобранныеТранзакцииSQL.type КАК type,
	|	СобранныеТранзакцииSQL.state КАК state,
	|	СобранныеТранзакцииSQL.num_reads КАК num_reads,
	|	СобранныеТранзакцииSQL.num_writes КАК num_writes,
	|	СобранныеТранзакцииSQL.client_ip КАК client_ip,
	|	СобранныеТранзакцииSQL.ib_name КАК ib_name,
	|	СобранныеТранзакцииSQL.wait_type КАК wait_type,
	|	СобранныеТранзакцииSQL.wait_time КАК wait_time,
	|	СобранныеТранзакцииSQL.sql_text_hash КАК sql_text_hash,
	|	СобранныеТранзакцииSQL.ДатаОбновления КАК ДатаОбновления,
	|	КомментарииПоТекстамSQLЗапросов.текстЗапросаSQL КАК текстЗапросаSQL,
	|	КомментарииПоТекстамSQLЗапросов.текстЗапроса1С КАК текстЗапроса1С,
	|	КомментарииПоТекстамSQLЗапросов.Комментарий КАК КомментарийПоЗапросу
	|ИЗ
	|	РегистрСведений.СобранныеТранзакцииSQL КАК СобранныеТранзакцииSQL
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КомментарииПоТекстамSQLЗапросов КАК КомментарииПоТекстамSQLЗапросов
	|		ПО СобранныеТранзакцииSQL.sql_text_hash = КомментарииПоТекстамSQLЗапросов.sql_text_hash
	|ГДЕ
	|	СобранныеТранзакцииSQL.СерверSQL = &СерверSQL
	|	И СобранныеТранзакцииSQL.ДатаНачала > &ДатаНачала
	|	И СобранныеТранзакцииSQL.ДатаОбновления = &ДатаОбновления";

	ТЧ_SQL = Запрос.Выполнить().Выгрузить();
	Для Каждого Строка_SQL Из ТЧ_SQL Цикл
		
		НоваяСтрока = АктивныеТранзакции.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка_SQL);
		
	КонецЦикла;
	
	ДатаОбновленияТранзакции = МестноеВремя(ДатаОбновления, ЧасовойПоясСеанса());
	
КонецПроцедуры


&НаСервере
Процедура ОбновитьДанныеНаСервере()
	
	ТекДата = ТекущаяУниверсальнаяДата();
	
	ОбновитьДанные_АктивныеЗапросыНаСервере(ТекДата);
	ОбновитьДанные_ТранзакцииНаСервере(ТекДата);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанныеТаблиц() Экспорт
	
	ОбновитьДанныеНаСервере();
	
	Если АвтообновлениеЗапущено Тогда
		Текст_ДекорацияАвтообновление = "Автообновление запущено; ";
	Иначе
		Текст_ДекорацияАвтообновление = "";
	КонецЕсли;
	Текст_ДекорацияАвтообновление = Текст_ДекорацияАвтообновление + "запуск: " + ТекущаяДата();
	
	Элементы.ДекорацияАвтообновление.Заголовок = Текст_ДекорацияАвтообновление;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанные(Команда)
	ОбновитьДанныеТаблиц();
КонецПроцедуры


&НаКлиенте
Процедура ЗапуститьАвтообновление(Команда)
	
	Если НЕ АвтообновлениеЗапущено Тогда
		
		// Проверка параметров, пусть лучше тут выкинет )))
		ОбновитьДанныеТаблиц();
		
		АвтообновлениеЗапущено = Истина;
		
		ИнтервалОбновления = ЧастотаОбновления;
		ИнтервалОбновления = Мин(ИнтервалОбновления, 5);
		
		ПодключитьОбработчикОжидания("ОбновитьДанныеТаблиц", ИнтервалОбновления);
		
	Иначе
		
		АвтообновлениеЗапущено = Ложь;
		ОтключитьОбработчикОжидания("ОбновитьДанныеТаблиц");
		
	КонецЕсли;
	
	ОбновитьЗаголовокКомандыАвтообновленияНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьЗаголовокКомандыАвтообновленияНаСервере()
	
	Если АвтообновлениеЗапущено Тогда
		Команды.ЗапуститьАвтообновление.Заголовок = "Отключить автообновление";
	Иначе
		Команды.ЗапуститьАвтообновление.Заголовок = "Запустить автообновление";
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УбитьПроцессНаСервере(НомерСеанса)
	
	ТекстЗапроса = "kill " + Формат(НомерСеанса, "ЧГ=");
	РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL);
	
КонецПроцедуры

&НаКлиенте
Процедура УбитьСеансЗапроса(Команда)

	Идент = Элементы.АктивныеЗапросы.ТекущиеДанные.ПолучитьИдентификатор();
	ТекСеанс = "0";
	АктивныеЗапросы.НайтиПоИдентификатору(Идент).Свойство("session",ТекСеанс);
	Если ТекСеанс = "0" ИЛИ НЕ ЗначениеЗаполнено(ТекСеанс) Тогда 
		Возврат;
	КонецЕсли;
	
	Ответ = Вопрос("Вы уверены, что необходимо убрать сеанс #№ " + ТекСеанс + "?",РежимДиалогаВопрос.ДаНет);
	Если Ответ = КодВозвратаДиалога.Да Тогда 
		УбитьПроцессНаСервере(ТекСеанс);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура УбитьСеансТранзакции(Команда)

	Идент = Элементы.АктивныеТранзакции.ТекущиеДанные.ПолучитьИдентификатор();
	ТекСеанс = "0";
	АктивныеТранзакции.НайтиПоИдентификатору(Идент).Свойство("session",ТекСеанс);
	Если ТекСеанс = "0" ИЛИ НЕ ЗначениеЗаполнено(ТекСеанс) Тогда 
		Возврат;
	КонецЕсли;
	
	Ответ = Вопрос("Вы уверены, что необходимо убрать сеанс #№ " + ТекСеанс + "?",РежимДиалогаВопрос.ДаНет);
	Если Ответ = КодВозвратаДиалога.Да Тогда 
		УбитьПроцессНаСервере(ТекСеанс);
	КонецЕсли;
	
КонецПроцедуры

