$parent = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$parent\Scripts\$sut"

Describe 'Write-TimeAndWord' {
    Context "First Test" {
        $word = "Hello"
        # Get-DateをMockで上書きする
        # Get-Dateを実行すると結果が"2017/03/31 06:00:00"に固定できる
        Mock Get-Date { return [String] "2017/03/31 06:00:00"}
        # Out-HostをMockで上書きする
        # "-parameterFilter"でパラメーターが指定したもの("2017/03/31 06:00:00")かチェックする
        Mock Out-Host -verifiable -parameterFilter { $_ -eq "Hello at 2017/03/31 06:00:00"}
        It 'return value' {
            # テストしたい関数を実行する
            Write-TimeAndWord $word
        }
        It "Assert-VerifiableMocks" {
            # "-verifiable"があるMockが呼び出されたかチェックする
            # 関数内でOut-Hostが呼び出されていれば問題なし
            Assert-VerifiableMocks
        }
        It "Assert-MockCalled" {
            # 関数内でMockのGet-Dateが2回呼び出されたかチェックする
            Assert-MockCalled -CommandName Get-Date -Times 2
            # 関数内でMockのOut-Hostが1回呼び出されたかチェックする
            Assert-MockCalled -CommandName Out-Host -Times 1
        }
    }
    Context "Second Test" {
        $word = "World"
        Mock Get-Date { return [String] "2017/03/31 06:00:00"}
        Mock Out-Host -parameterFilter { $_ -eq "World at 2017/03/31 06:00:00"}
        It "All Test" {
            Write-TimeAndWord $word   
            Assert-VerifiableMocks         
            Assert-MockCalled -CommandName Get-Date -Times 1
            Assert-MockCalled -CommandName Out-Host -Times 1
        }
    }
} 