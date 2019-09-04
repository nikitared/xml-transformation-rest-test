package ru.babaninnv.edisoft.test.web;

import com.google.common.collect.Lists;
import org.apache.commons.lang3.time.DateUtils;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.http.HttpHeaders;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import ru.babaninnv.edisoft.test.domain.XmlFile;
import ru.babaninnv.edisoft.test.repositories.XmlFileRepository;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Optional;
import java.util.TimeZone;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;

@RunWith(SpringRunner.class)
public class XmlFileRestControllerTest {

    static {
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
    }

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd-MM-yyyy hh:mm:ss");

    private MockMvc mockMvc;

    private XmlFileRepository xmlFileRepository;

    @Before
    public void before() {
        xmlFileRepository = mock(XmlFileRepository.class);

        XmlFileRestController controller = new XmlFileRestController(xmlFileRepository);
        this.mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .build();
    }

    @Test
    public void files() throws Exception {
        Date date = new Date();
        ArrayList<XmlFile> xmlFiles = Lists.newArrayList(new XmlFile(1L, "name1", date),
                new XmlFile(2L, "name2", DateUtils.addDays(date, 1)));
        when(xmlFileRepository.findAll()).thenReturn(xmlFiles);

        mockMvc.perform(get("/files"))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].id").value(xmlFiles.get(0).getId()))
                .andExpect(jsonPath("$[0].originalName").value(xmlFiles.get(0).getOriginalName()))
                .andExpect(jsonPath("$[0].receiveDate").value(DATE_FORMAT.format(xmlFiles.get(0).getReceiveDate())))
                .andExpect(jsonPath("$[1].id").value(xmlFiles.get(1).getId()))
                .andExpect(jsonPath("$[1].originalName").value(xmlFiles.get(1).getOriginalName()))
                .andExpect(jsonPath("$[1].receiveDate").value(DATE_FORMAT.format(xmlFiles.get(1).getReceiveDate())))
                .andReturn();
    }

    @Test
    public void files_When_listIsEmpty() throws Exception {
        ArrayList<XmlFile> xmlFiles = Lists.newArrayList();
        when(xmlFileRepository.findAll()).thenReturn(xmlFiles);

        mockMvc.perform(get("/files"))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(jsonPath("$", hasSize(0)))
                .andReturn();
    }

    @Test
    public void download() throws Exception {
        XmlFile xmlFile = new XmlFile();
        xmlFile.setOriginalName("test.txt");
        xmlFile.setTransformedFile("123123123".getBytes());
        when(xmlFileRepository.findAttachment(anyLong())).thenReturn(Optional.of(xmlFile));

        mockMvc.perform(get("/files/download/1"))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.content().bytes("123123123".getBytes()))
                .andExpect(MockMvcResultMatchers.header().string(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"test.txt\""))
                .andReturn();
    }

    @Test
    public void download_When_xmlFileNotFound() throws Exception {
        when(xmlFileRepository.findAttachment(anyLong())).thenReturn(Optional.empty());

        mockMvc.perform(get("/files/download/1"))
                .andExpect(MockMvcResultMatchers.status().isNotFound())
                .andReturn();
    }
}