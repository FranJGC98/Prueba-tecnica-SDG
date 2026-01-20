from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

# Función para interactuar con MinIO (S3)
def upload_to_minio_logic():
    # 'minio_s3' es el ID que configuramos en el Terraform
    s3 = S3Hook(aws_conn_id='minio_s3')
    
    # Creamos un contenido simple con la fecha actual
    mensaje = f"Prueba E2E completada con éxito el {datetime.now()}"
    nombre_archivo = f"pruebas/resultado_{datetime.now().strftime('%Y%m%d_%H%M')}.txt"
    
    # Subimos el archivo al bucket (asegúrate de que el bucket exista o créalo en la UI de MinIO)
    s3.load_string(
        string_data=mensaje,
        key=nombre_archivo,
        bucket_name="data-bucket",
        replace=True
    )
    print(f"Archivo subido a MinIO: {nombre_archivo}")

# Configuración del DAG
default_args = {
    'owner': 'data_engineering',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='e2e_data_stack_test',
    default_args=default_args,
    description='Prueba de integración: Airflow -> Postgres -> MinIO',
    start_date=datetime(2025, 1, 1),
    schedule_interval="*/1 * * * *", # Se lanza cada 120 segundos
    is_paused_upon_creation=False,
    catchup=False,
    tags=['e2e', 'testing']
) as dag:

    # 1. Tarea de Base de Datos: Crea una tabla de auditoría e inserta un registro
    # Usamos 'postgres_default' que ya viene preconfigurado en tu Terraform
    task_postgres = PostgresOperator(
        task_id='verify_postgres_connection',
        postgres_conn_id='postgres_default',
        sql="""
            CREATE TABLE IF NOT EXISTS e2e_logs (
                id SERIAL PRIMARY KEY,
                execution_date TIMESTAMP,
                status TEXT
            );
            INSERT INTO e2e_logs (execution_date, status) 
            VALUES (CURRENT_TIMESTAMP, 'Airflow connected');
        """
    )

    # 2. Tarea de Storage: Sube un reporte a MinIO
    task_minio = PythonOperator(
        task_id='verify_minio_connection',
        python_callable=upload_to_minio_logic
    )

    # Definimos el flujo: primero DB, luego Storage
    task_postgres >> task_minio