using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.Diagnostics;
using System.Collections.Immutable;
using System.Diagnostics;
using System.Linq;

namespace FunctionPurityAnalyzer
{
    public class TestSyntaxWalker : CSharpSyntaxWalker
    {
        private CompilationAnalysisContext _context;
        private ISymbol _containingFunctionSymbol;

        public TestSyntaxWalker(CompilationAnalysisContext context)
        {
            _context = context;
        }

        public override void VisitMethodDeclaration(MethodDeclarationSyntax node)
        {
            SemanticModel semanticModel = _context.Compilation.GetSemanticModel(node.SyntaxTree);
            _containingFunctionSymbol = semanticModel.GetDeclaredSymbol(node);

            base.VisitMethodDeclaration(node);
        }

        public override void VisitLocalFunctionStatement(LocalFunctionStatementSyntax node)
        {
            SemanticModel semanticModel = _context.Compilation.GetSemanticModel(node.SyntaxTree);
            _containingFunctionSymbol = semanticModel.GetDeclaredSymbol(node);

            base.VisitLocalFunctionStatement(node);
        }

        public override void VisitAnonymousMethodExpression(AnonymousMethodExpressionSyntax node)
        {
            SemanticModel semanticModel = _context.Compilation.GetSemanticModel(node.SyntaxTree);
            _containingFunctionSymbol = semanticModel.GetDeclaredSymbol(node);

            base.VisitAnonymousMethodExpression(node);
        }

        public override void VisitParenthesizedLambdaExpression(ParenthesizedLambdaExpressionSyntax node)
        {
            SemanticModel semanticModel = _context.Compilation.GetSemanticModel(node.SyntaxTree);
            _containingFunctionSymbol = semanticModel.GetDeclaredSymbol(node);

            base.VisitParenthesizedLambdaExpression(node);
        }

        public override void VisitSimpleLambdaExpression(SimpleLambdaExpressionSyntax node)
        {
            SemanticModel semanticModel = _context.Compilation.GetSemanticModel(node.SyntaxTree);
            _containingFunctionSymbol = semanticModel.GetDeclaredSymbol(node);

            base.VisitSimpleLambdaExpression(node);
        }

        public override void VisitInvocationExpression(InvocationExpressionSyntax node)
        {
            base.VisitInvocationExpression(node);

            SemanticModel semanticModel = _context.Compilation.GetSemanticModel(node.SyntaxTree);

            var symbolInfo = semanticModel.GetSymbolInfo(node);
        }
    }

    [DiagnosticAnalyzer(LanguageNames.CSharp)]
    public class FunctionPurityAnalyzer : DiagnosticAnalyzer
    {
        public const string DiagnosticId = "FunctionPurityAnalyzer";

        private static readonly string Title = "Test1";
        private static readonly string MessageFormat = "Test2";
        private static readonly string Description = "Test3.";
        private const string Category = "Naming";

        private static readonly DiagnosticDescriptor Rule = new DiagnosticDescriptor(DiagnosticId, Title, MessageFormat, Category, DiagnosticSeverity.Error, isEnabledByDefault: true, description: Description);

        public override ImmutableArray<DiagnosticDescriptor> SupportedDiagnostics { get { return ImmutableArray.Create(Rule); } }

        public override void Initialize(AnalysisContext context)
        {
            if (!Debugger.IsAttached)
            {
                Debugger.Launch();
            }

            context.ConfigureGeneratedCodeAnalysis(GeneratedCodeAnalysisFlags.None);
            context.EnableConcurrentExecution();

            context.RegisterCompilationAction(AnalyzeCompilation);
        }

        private static void AnalyzerOperation()
        {

        }

        private static void AnalyzeCompilation(CompilationAnalysisContext context)
        {
            foreach (var syntaxTree in context.Compilation.SyntaxTrees)
            {
                CompilationUnitSyntax compilationUnit = syntaxTree.GetCompilationUnitRoot();

                var walker = new TestSyntaxWalker(context);
                walker.Visit(compilationUnit);
            }
            //var diagnostic = Diagnostic.Create(Rule, context.Compilation.SyntaxTrees.FirstOrDefault()?.GetRoot().GetLocation());
            //context.ReportDiagnostic(diagnostic);
        }

        public static bool IsPure(IMethodSymbol methodSymbol)
        {
            return false;
        }

        public static SyntaxNode GetContainingFunctionNode(SyntaxNode node) =>
            node.Ancestors()
                .First(n =>
                       n is MethodDeclarationSyntax
                    || n is LocalFunctionStatementSyntax
                    || n is AnonymousFunctionExpressionSyntax);
    }
}
