"""
Terminal display utilities for A2A Scanner Lab
Provides color-coded output and formatting helpers
"""

from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.text import Text

# Initialize rich console
console = Console()


def print_header(title):
    """Print a formatted header"""
    console.print()
    console.print("=" * 50, style="bold cyan")
    console.print(title, style="bold cyan", justify="center")
    console.print("=" * 50, style="bold cyan")
    console.print()


def print_section(title):
    """Print a section divider"""
    console.print()
    console.print(f"[bold blue]{title}[/bold blue]")
    console.print("─" * 50)
    console.print()


def print_success(message):
    """Print a success message"""
    console.print(f"✓ {message}", style="bold green")


def print_warning(message):
    """Print a warning message"""
    console.print(f"⚠️  {message}", style="bold yellow")


def print_error(message):
    """Print an error message"""
    console.print(f"✗ {message}", style="bold red")


def print_info(message):
    """Print an info message"""
    console.print(f"ℹ️  {message}", style="bold blue")


def print_severity(severity, message):
    """Print a message with severity-based color coding"""
    severity_upper = severity.upper()
    
    if severity_upper == "HIGH":
        console.print(f"🚨 HIGH: {message}", style="bold red")
    elif severity_upper == "MEDIUM":
        console.print(f"⚠️  MEDIUM: {message}", style="bold yellow")
    elif severity_upper == "LOW":
        console.print(f"ℹ️  LOW: {message}", style="bold blue")
    else:
        console.print(f"• {message}")


def create_results_table(findings):
    """Create a formatted table of scan results"""
    table = Table(title="Scan Results", show_header=True, header_style="bold magenta")
    
    table.add_column("Severity", style="bold", justify="center", width=10)
    table.add_column("Threat", style="bold", width=30)
    table.add_column("Details", width=50)
    
    for finding in findings:
        severity = finding.get("severity", "UNKNOWN")
        threat_name = finding.get("threat_name", "Unknown Threat")
        summary = finding.get("summary", "No details available")
        
        # Color code by severity
        if severity == "HIGH":
            severity_text = Text("HIGH", style="bold red")
        elif severity == "MEDIUM":
            severity_text = Text("MEDIUM", style="bold yellow")
        elif severity == "LOW":
            severity_text = Text("LOW", style="bold blue")
        else:
            severity_text = Text(severity)
        
        table.add_row(severity_text, threat_name, summary)
    
    return table


def print_scan_summary(total_scanned, passed, warnings, failed):
    """Print a summary of scan results"""
    console.print()
    console.print(Panel.fit(
        f"[bold]Total Agents Scanned:[/bold] {total_scanned}\n"
        f"[bold green]✓ Passed:[/bold green] {passed}\n"
        f"[bold yellow]⚠️  Warnings:[/bold yellow] {warnings}\n"
        f"[bold red]✗ Failed:[/bold red] {failed}",
        title="Scan Summary",
        border_style="cyan"
    ))
    console.print()


def print_threat_breakdown(high, medium, low):
    """Print threat severity breakdown"""
    console.print()
    console.print("[bold]Threat Severity Breakdown:[/bold]")
    console.print(f"  [bold red]🚨 HIGH:[/bold red] {high} findings")
    console.print(f"  [bold yellow]⚠️  MEDIUM:[/bold yellow] {medium} findings")
    console.print(f"  [bold blue]ℹ️  LOW:[/bold blue] {low} findings")
    console.print()


def print_progress(current, total, description="Processing"):
    """Print progress indicator"""
    percentage = (current / total) * 100 if total > 0 else 0
    console.print(f"[{current}/{total}] {description}... ({percentage:.0f}%)")


if __name__ == "__main__":
    # Demo of utilities
    print_header("A2A Scanner Display Utilities Demo")
    
    print_section("Status Messages")
    print_success("This is a success message")
    print_warning("This is a warning message")
    print_error("This is an error message")
    print_info("This is an info message")
    
    print_section("Severity Messages")
    print_severity("HIGH", "Critical security threat detected")
    print_severity("MEDIUM", "Moderate security concern")
    print_severity("LOW", "Minor issue found")
    
    print_section("Example Results Table")
    example_findings = [
        {
            "severity": "HIGH",
            "threat_name": "Agent Impersonation",
            "summary": "Suspicious agent identity detected"
        },
        {
            "severity": "MEDIUM",
            "threat_name": "Prompt Injection",
            "summary": "Directive patterns found in description"
        },
        {
            "severity": "LOW",
            "threat_name": "Missing Field",
            "summary": "Optional field 'contact' not present"
        }
    ]
    console.print(create_results_table(example_findings))
    
    print_section("Scan Summary")
    print_scan_summary(total_scanned=5, passed=2, warnings=1, failed=2)
    
    print_threat_breakdown(high=3, medium=2, low=1)
