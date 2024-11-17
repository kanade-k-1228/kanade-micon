import re


def parse_yosys_log(file_path):
    with open(file_path, "r") as file:
        log_data = file.read()

    print(log_data)
    module_usage = {}
    module_pattern = re.compile(r"=== (\S+) ===\n.*?LCs:\s+(\d+)", re.DOTALL)

    for match in module_pattern.finditer(log_data):
        module_name = match.group(1)
        lc_count = int(match.group(2))
        module_usage[module_name] = lc_count

    return module_usage


if __name__ == "__main__":
    log_file_path = "src/build/hw.json.log"
    usage = parse_yosys_log(log_file_path)
    for module, lc_count in usage.items():
        print(f"Module: {module}, LCs: {lc_count}")
