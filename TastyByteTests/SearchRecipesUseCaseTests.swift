import XCTest
@testable import TastyByte

/// Prueba `SearchRecipesUseCase` con un `RecipeRepository` falso.
/// No abre red, SQLite ni UIKit: el caso de uso solo reenvía el texto y el resultado.
final class SearchRecipesUseCaseTests: XCTestCase {

    func testEmptyQueryRequestsTheBaseCatalog() async throws {
        let catalog = [makeRecipe(id: "52768", title: "Apple Frangipan Tart")]
        let repository = FakeRecipeRepository(result: .success(catalog))
        let useCase = SearchRecipesUseCase(repository: repository)

        let recipes = try await useCase.execute(query: "")

        XCTAssertEqual(recipes, catalog)
        XCTAssertEqual(repository.receivedQueries, [""])
    }

    func testQueryReturnsTheRepositoryList() async throws {
        let list = [
            makeRecipe(id: "52772", title: "Teriyaki Chicken"),
            makeRecipe(id: "52846", title: "Chicken & mushroom Hotpot")
        ]
        let repository = FakeRecipeRepository(result: .success(list))
        let useCase = SearchRecipesUseCase(repository: repository)

        let recipes = try await useCase.execute(query: "Chicken")

        XCTAssertEqual(recipes, list)
        XCTAssertEqual(repository.receivedQueries, ["Chicken"])
    }

    func testRepositoryErrorIsPropagated() async {
        let repository = FakeRecipeRepository(result: .failure(FakeRecipeError.unavailable))
        let useCase = SearchRecipesUseCase(repository: repository)

        do {
            _ = try await useCase.execute(query: "Pasta")
            XCTFail("Se esperaba que el caso de uso propagara el error del repositorio")
        } catch let error as FakeRecipeError {
            XCTAssertEqual(error, .unavailable)
            XCTAssertEqual(repository.receivedQueries, ["Pasta"])
        } catch {
            XCTFail("Error inesperado: \(error)")
        }
    }
}

private func makeRecipe(id: String, title: String) -> Recipe {
    Recipe(
        id: id,
        title: title,
        category: "Chicken",
        area: "Japanese",
        instructions: "Cook it.",
        imageURL: nil
    )
}

private enum FakeRecipeError: Error, Equatable {
    case unavailable
}

/// Doble de `RecipeRepository`. Guarda el texto recibido y devuelve el resultado fijado en el init.
private final class FakeRecipeRepository: RecipeRepository, @unchecked Sendable {
    private let result: Result<[Recipe], Error>
    private(set) var receivedQueries: [String] = []

    init(result: Result<[Recipe], Error>) {
        self.result = result
    }

    func search(query: String) async throws -> [Recipe] {
        receivedQueries.append(query)
        return try result.get()
    }
}
