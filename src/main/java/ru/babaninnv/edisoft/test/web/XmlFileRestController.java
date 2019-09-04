package ru.babaninnv.edisoft.test.web;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.babaninnv.edisoft.test.domain.XmlFile;
import ru.babaninnv.edisoft.test.repositories.XmlFileRepository;

import java.util.List;
import java.util.Optional;

import static org.springframework.http.ContentDisposition.builder;

@RestController
@RequestMapping("/files")
public class XmlFileRestController {

    private final XmlFileRepository xmlFileRepository;

    public XmlFileRestController(XmlFileRepository xmlFileRepository) {
        this.xmlFileRepository = xmlFileRepository;
    }

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public List<XmlFile> files() {
        return xmlFileRepository.findAll();
    }

    @GetMapping(value = "/download/{id}")
    public ResponseEntity<byte[]> download(@PathVariable("id") Long id) {
        Optional<XmlFile> transformedFile = xmlFileRepository.findAttachment(id);
        return transformedFile
                .map(xmlFile -> ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_DISPOSITION, builder("attachment")
                                .filename("transformed".concat(xmlFile.getOriginalName()))
                                .build().toString())
                        .body(xmlFile.getTransformedFile()))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
}