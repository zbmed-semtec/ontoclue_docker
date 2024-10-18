from pytest import fixture

def pytest_addoption(parser):
    parser.addoption(
        "--annotated_data",
        action="store"
    )
    parser.addoption(
        "--category",
        action="store"
    )
    parser.addoption(
        "--algorithm",
        action="store"
    )


@fixture()
def annotated_data(request):
    return request.config.getoption("--annotated_data")

@fixture()
def category(request):
    return request.config.getoption("--category")

@fixture()
def algorithm(request):
    return request.config.getoption("--algorithm")