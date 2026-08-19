import time, random
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

trace.set_tracer_provider(TracerProvider())
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="localhost:4317", insecure=True))
)
tracer = trace.get_tracer("shop")

def db_lookup():
    with tracer.start_as_current_span("db.lookup"):
        time.sleep(random.uniform(0.05, 0.2))

def charge():
    with tracer.start_as_current_span("payment.charge"):
        time.sleep(random.uniform(0.1, 0.3))

def checkout():
    with tracer.start_as_current_span("http.checkout"):
        db_lookup()
        charge()

for _ in range(5):
    checkout()
    time.sleep(0.3)
print("traces sent")
