package com.tlc.test.scheduler;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.JobParametersInvalidException;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.repository.JobExecutionAlreadyRunningException;
import org.springframework.batch.core.repository.JobInstanceAlreadyCompleteException;
import org.springframework.batch.core.repository.JobRestartException;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Slf4j
@Component
@RequiredArgsConstructor
public class SimpleBatchScheduler {
    private final Job job;
    private final JobLauncher jobLauncher;

    @Scheduled(fixedDelay = 100)
    public void executeJob() {
        try {
            jobLauncher.run(job,
                    new JobParametersBuilder()
                            .addString("datetime",
                                    LocalDateTime.now().toString())
                            .toJobParameters()
            );
        } catch (JobExecutionAlreadyRunningException e) {
            log.error("SimpleBatchScheduler JobExecutionAlreadyRunningException: {}", e.getMessage());
            throw new RuntimeException(e);
        } catch (JobRestartException e) {
            log.error("SimpleBatchScheduler JobRestartException: {}", e.getMessage());
            throw new RuntimeException(e);
        } catch (JobInstanceAlreadyCompleteException e) {
            log.error("SimpleBatchScheduler JobInstanceAlreadyCompleteException: {}", e.getMessage());
            throw new RuntimeException(e);
        } catch (JobParametersInvalidException e) {
            log.error("SimpleBatchScheduler JobParametersInvalidException: {}", e.getMessage());
            throw new RuntimeException(e);
        }
    }
}
