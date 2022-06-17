///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриЗаполненииТиповТребующихАннотациюСсылокПриВыгрузке
Процедура ПриЗаполненииТиповТребующихАннотациюСсылокПриВыгрузке(Типы) Экспорт
	
	Типы.Добавить(Метаданные.Справочники.Пользователи);
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриРегистрацииОбработчиковВыгрузкиДанных.
Процедура ПриРегистрацииОбработчиковВыгрузкиДанных(ТаблицаОбработчиков) Экспорт
	
	ОбъектОбработчика = Создать();
	
	НовыйОбработчик = ТаблицаОбработчиков.Добавить();
	НовыйОбработчик.ОбъектМетаданных = Метаданные.Справочники.Пользователи;
	НовыйОбработчик.Обработчик = ОбъектОбработчика;
	НовыйОбработчик.ПередВыгрузкойДанных = Истина;
	НовыйОбработчик.ПередВыгрузкойОбъекта = Истина;
	НовыйОбработчик.ПослеВыгрузкиОбъекта = Истина;
	НовыйОбработчик.Версия = "1.0.0.1";
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриРегистрацииОбработчиковЗагрузкиДанных.
Процедура ПриРегистрацииОбработчиковЗагрузкиДанных(ТаблицаОбработчиков) Экспорт
	
	ОбъектОбработчика = Создать();
	
	НовыйОбработчик = ТаблицаОбработчиков.Добавить();
	НовыйОбработчик.ОбъектМетаданных = Метаданные.Справочники.Пользователи;
	НовыйОбработчик.Обработчик = ОбъектОбработчика;
	НовыйОбработчик.ПередЗагрузкойДанных = Истина;
	НовыйОбработчик.ПередСопоставлениемСсылок = Истина;
	НовыйОбработчик.ПередЗагрузкойОбъекта = Истина;
	НовыйОбработчик.Версия = "1.0.0.1";
	
	СписокРегистров = ПользователиСлужебныйВМоделиСервисаПовтИсп.СписокНаборовЗаписейСоСсылкамиНаПользователей();
	Для Каждого ЭлементСписка Из СписокРегистров Цикл
		
		НовыйОбработчик = ТаблицаОбработчиков.Добавить();
		НовыйОбработчик.ОбъектМетаданных = ЭлементСписка.Ключ;
		НовыйОбработчик.Обработчик = ОбъектОбработчика;
		НовыйОбработчик.ПередЗагрузкойТипа = Истина;
		НовыйОбработчик.ПередЗагрузкойОбъекта = Истина;
		НовыйОбработчик.Версия = "1.0.0.1";
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли