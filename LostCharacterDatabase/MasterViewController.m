//
//  ViewController.m
//  LostCharacterDatabase
//
//  Created by Apple on 28/01/14.
//  Copyright (c) 2014 Tablified Solutions. All rights reserved.
//

#import "MasterViewController.h"
#import "Character.h"
#import "LostTableViewCell.h"
#import "SearchTableView.h"
@import CoreData;

@interface MasterViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>
{

    NSArray *lostCharacters;
    __weak IBOutlet SearchTableView *myTableView;
    __weak IBOutlet UITextField *passengerTextField;
    __weak IBOutlet UITextField *actorTextField;
    __weak IBOutlet UITextField *appearancesTextField;
    __weak IBOutlet UISearchBar *mySearchBar;
    
}

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self reload];
    [self loadFromPList];
    mySearchBar.delegate = self;
    myTableView.searchResults = [NSMutableArray arrayWithCapacity:[lostCharacters count]];
}

-(void)loadFromPList
{
    if (lostCharacters.count == 0)
    {
        lostCharacters = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lost" ofType:@"plist"]];
        
        for (NSDictionary *dictionary in lostCharacters)
        {
            Character *character = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:_managedObjectContext];
            character.passenger = dictionary[@"passenger"];
            character.actor = dictionary[@"actor"];
            character.appearances = dictionary[@"appearances"];
            
            [_managedObjectContext save:nil];
        }
        [self reload];
    }
}

-(void)reload
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Character"];
    
    NSSortDescriptor *sortDescriptior = [[NSSortDescriptor alloc] initWithKey:@"appearances" ascending:NO];
    request.sortDescriptors = @[sortDescriptior];
    
    lostCharacters = [_managedObjectContext executeFetchRequest:request error:nil];
    
    [myTableView reloadData];
}

- (IBAction)onAddButtonPressed:(id)sender {
    Character *character = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:_managedObjectContext];
    character.actor = actorTextField.text;
    character.passenger = passengerTextField.text;
    character.appearances = @(appearancesTextField.text.intValue);
    
    [actorTextField resignFirstResponder];
    [passengerTextField resignFirstResponder];
    [appearancesTextField resignFirstResponder];

    [_managedObjectContext save:nil];
    [self reload];
}


-(NSInteger)tableView:(SearchTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (myTableView == self.searchDisplayController.searchResultsTableView)
    {
        return myTableView.searchResults.count;
        
    } else {
        return lostCharacters.count;
    }
    
}

-(LostTableViewCell *)tableView:(SearchTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LostTableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"LostID"];
    
    Character *character;
    
    if (myTableView == self.searchDisplayController.searchResultsTableView)
    {
        character = myTableView.searchResults[indexPath.row];
        
        
    } else {
        character = lostCharacters[indexPath.row];
    }
    
    cell.characterLabel.text = character.passenger;
    cell.actorLabel.text = character.actor;
    cell.appearancesLabel.text = character.appearances.description;
    [cell.characterLabel sizeToFit];
    [cell.actorLabel sizeToFit];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(SearchTableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_managedObjectContext deleteObject:lostCharacters[indexPath.row]];
        [_managedObjectContext save:nil];
        [self reload];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"SMOKE MONSTER";
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [myTableView.searchResults removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    
    NSMutableArray *searchArray = [NSMutableArray new];
    for (int i = 0; i < lostCharacters.count; i++)
    {
        Character *character = lostCharacters[i];
        [searchArray addObject:character.passenger];
    }
    
    myTableView.searchResults = [NSMutableArray arrayWithArray:[searchArray filteredArrayUsingPredicate:resultPredicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

@end
