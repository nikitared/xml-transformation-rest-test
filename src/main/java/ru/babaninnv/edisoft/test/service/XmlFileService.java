package ru.babaninnv.edisoft.test.service;

import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

import ru.babaninnv.edisoft.test.domain.XmlFile;
import ru.babaninnv.edisoft.test.repositories.XmlFileRepository;

/**
 * Сервис для работы с объектом XmlFile
 *
 * @author Nikita Babanin
 * @version 1.0
 */
@Service("xmlFileService")
public class XmlFileService {

    private final XmlFileRepository xmlFileRepository;

    public XmlFileService(XmlFileRepository xmlFileRepository) {
        this.xmlFileRepository = xmlFileRepository;
    }

    /**
     * По идентификатору файла возвращает объект XmlFile
     * с заполненным контентом преобразованного и наименованием оригинального файла
     *
     * @param id идентификатор XML-файла
     */
    public XmlFile getTransformedFile(Long id) {
        return xmlFileRepository.findAttachment(id);
    }

    /**
     * Возвращает список всех записей типа XmlFile
     */
    public List<XmlFile> findAll() {
        return xmlFileRepository.findAll();
    }

    /**
     * Создаёт экземпляр XmlFile с заданным наименованием оригинального
     * файла и контентом оригинального файла и преобразованного
     *
     * @param originalFileName наименование оригинального файла
     * @param originalFileContent контент оригинального файла
     * @param transformedFileContent контент преобразованного файла
     * @return заполненный экземпляр класса XmlFile
     */
    public XmlFile create(String originalFileName, byte[] originalFileContent, byte[] transformedFileContent) {

        XmlFile xmlFile = new XmlFile();
        xmlFile.setOriginalName(originalFileName);
        xmlFile.setReceiveDate(new Date());
        xmlFile.setOriginalFile(originalFileContent);
        xmlFile.setTransformedFile(transformedFileContent);

        return xmlFile;
    }
}
