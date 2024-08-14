-- DB Version: 14
-- OS Type: linux
-- DB Type: oltp
-- Total Memory (RAM): 6 GB
-- CPUs num: 6
-- Connections num: 200
-- Data Storage: ssd

ALTER SYSTEM SET
 max_connections = '200';
ALTER SYSTEM SET
 shared_buffers = '1536MB';
ALTER SYSTEM SET
 effective_cache_size = '4608MB';
ALTER SYSTEM SET
 maintenance_work_mem = '384MB';
ALTER SYSTEM SET
 checkpoint_completion_target = '0.9';
ALTER SYSTEM SET
 wal_buffers = '16MB';
ALTER SYSTEM SET
 default_statistics_target = '100';
ALTER SYSTEM SET
 random_page_cost = '1.1';
ALTER SYSTEM SET
 effective_io_concurrency = '200';
ALTER SYSTEM SET
 work_mem = '2621kB';
ALTER SYSTEM SET
 huge_pages = 'off';
ALTER SYSTEM SET
 min_wal_size = '2GB';
ALTER SYSTEM SET
 max_wal_size = '8GB';
ALTER SYSTEM SET
 max_worker_processes = '6';
ALTER SYSTEM SET
 max_parallel_workers_per_gather = '3';
ALTER SYSTEM SET
 max_parallel_workers = '6';
ALTER SYSTEM SET
 max_parallel_maintenance_workers = '3';
